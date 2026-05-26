#!/usr/bin/env python3
"""Local read-only HTML cockpit for Orchestia."""

from __future__ import annotations

import argparse
import html
import os
import re
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import subprocess
import sys
from urllib.parse import parse_qs, quote, unquote, urlparse


DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 8765
MAX_TEXT_BYTES = 200 * 1024
MAX_POST_BYTES = 64 * 1024

LOGICS_GROUPS = [
    ("Initial needs", "logics/initial-needs"),
    ("Primary needs", "logics/primary-needs"),
    ("Loop states", "logics/loop-states"),
    ("Requests", "logics/requests"),
    ("Backlog", "logics/backlog"),
    ("Tasks", "logics/tasks"),
    ("Reviews", "logics/reviews"),
    ("ADRs", "logics/adr"),
    ("Templates", "logics/templates"),
]

EXPECTED_FOLDERS = [
    "docs",
    "prompts",
    "scripts",
    "logics",
    "logics/loop-states",
    "logics/reviews",
    "task-runs",
]

EXPECTED_SCRIPTS = [
    "scripts/orchestia_loop.sh",
    "scripts/controlled_git_flow.sh",
    "scripts/check_environment.sh",
    "scripts/audit_repo.sh",
]

SECRET_NAMES = {
    ".env",
    "hosts.yml",
    "id_rsa",
    "id_dsa",
    "id_ecdsa",
    "id_ed25519",
    "known_hosts",
}

SECRET_PARTS = [
    "token",
    "secret",
    "credential",
    "credentials",
    "password",
    "passwd",
    "private_key",
]


def is_under_mnt_c(path: Path) -> bool:
    value = str(path)
    return value == "/mnt/c" or value.startswith("/mnt/c/")


def esc(value: object) -> str:
    return html.escape(str(value), quote=True)


def run_git(repo: Path, args: list[str], timeout: int = 10) -> str:
    try:
        result = subprocess.run(
            ["git", *args],
            cwd=repo,
            text=True,
            capture_output=True,
            timeout=timeout,
            check=False,
        )
    except Exception as exc:  # noqa: BLE001 - UI should degrade gracefully.
        return f"(git command failed: {exc})"

    output = result.stdout.strip()
    if result.returncode != 0:
        error = result.stderr.strip()
        if error:
            return f"(git exited {result.returncode})\n{error}"
        return f"(git exited {result.returncode})"
    return output


def safe_join(repo: Path, rel_path: str) -> Path:
    decoded = unquote(rel_path or "")
    if decoded.startswith("/"):
        raise ValueError("absolute paths are not allowed")
    candidate = (repo / decoded).resolve()
    try:
        candidate.relative_to(repo)
    except ValueError as exc:
        raise ValueError("path escapes repository root") from exc
    return candidate


def is_hidden_or_git(path: Path, repo: Path) -> bool:
    try:
        parts = path.relative_to(repo).parts
    except ValueError:
        return True
    return any(part.startswith(".") for part in parts) or ".git" in parts


def is_secret_like(path: Path) -> bool:
    name = path.name.lower()
    if name in SECRET_NAMES or name.startswith(".env"):
        return True
    return any(part in name for part in SECRET_PARTS)


def safe_file_allowed(path: Path, repo: Path) -> tuple[bool, str]:
    if not path.exists() or not path.is_file():
        return False, "file not found"
    if is_hidden_or_git(path, repo):
        return False, "hidden files and .git paths are not shown"
    if is_secret_like(path):
        return False, "secret-like files are not shown"
    if path.stat().st_size > MAX_TEXT_BYTES:
        return False, "file is larger than 200 KB"
    data = path.read_bytes()
    if b"\x00" in data[:4096]:
        return False, "binary-looking files are not shown"
    return True, ""


def read_text_file(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def rel(repo: Path, path: Path) -> str:
    return path.resolve().relative_to(repo).as_posix()


def utc_timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def utc_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def first_value(data: dict[str, list[str]], name: str, limit: int = 8000) -> str:
    value = data.get(name, [""])[0]
    value = value.replace("\r\n", "\n").replace("\r", "\n")
    return value[:limit].strip()


def file_link(repo: Path, path: Path, label: str | None = None) -> str:
    path_rel = rel(repo, path)
    text = label or path.name
    return f'<a href="/file?path={quote(path_rel)}">{esc(text)}</a>'


def route_link(path: str, label: str) -> str:
    return f'<a href="{esc(path)}">{esc(label)}</a>'


def field_value(text: str, labels: list[str]) -> str:
    wanted = [label.lower() for label in labels]
    for line in text.splitlines():
        stripped = line.strip()
        normalized = stripped.lstrip("-* ").lower()
        for label in wanted:
            if normalized.startswith(label):
                parts = stripped.split(":", 1)
                if len(parts) == 2:
                    return parts[1].strip() or "None"
    return "None"


def loop_fields(text: str) -> dict[str, str]:
    return {
        "current_primary_need": field_value(text, ["current primary need"]),
        "current_request": field_value(text, ["current request"]),
        "current_backlog": field_value(text, ["current backlog", "current backlog item"]),
        "current_task": field_value(text, ["current task"]),
        "prepared_codex_prompt": field_value(text, ["prepared codex prompt"]),
        "decision": field_value(text, ["decision"]),
        "next_action": field_value(text, ["next action"]),
        "stop_condition": field_value(text, ["stop condition"]),
        "last_review": field_value(text, ["last review"]),
        "last_codex_run": field_value(text, ["last codex run"]),
    }


def review_decision(text: str) -> str:
    direct = field_value(text, ["decision"])
    if direct != "None":
        for value in ("accept", "revise", "split", "reject"):
            if value in direct.lower():
                return value
        return direct
    lowered = text.lower()
    for value in ("accept", "revise", "split", "reject"):
        if value in lowered:
            return value
    return "None"


def list_markdown(root: Path) -> list[Path]:
    if not root.exists():
        return []
    return sorted(path for path in root.glob("*.md") if path.is_file() and not path.name.startswith("."))


def count_files(repo: Path, folder: str) -> int:
    return len(list_markdown(repo / folder))


def infer_run_type(path: Path) -> str:
    name = path.name.lower()
    if "repo-audit" in name:
        return "repo-audit"
    if "diff" in name:
        return "diff"
    if "test" in name:
        return "tests"
    if "controlled-git-flow" in name:
        return "controlled-git-flow"
    if "git-flow-handoff" in name:
        return "git-flow-handoff"
    if "git-flow-review" in name:
        return "git-flow-review-draft"
    if "auto-loop" in name:
        return "auto-loop"
    if "autonomous-loop" in name:
        return "autonomous-loop"
    return "unknown"


def auto_loop_dirs(repo: Path) -> list[Path]:
    root = repo / "task-runs"
    if not root.exists():
        return []
    return sorted(
        (path for path in root.glob("*-auto-loop") if path.is_dir() and not path.name.startswith(".")),
        key=lambda path: path.name,
        reverse=True,
    )


def autonomous_loop_dirs(repo: Path) -> list[Path]:
    root = repo / "task-runs"
    if not root.exists():
        return []
    return sorted(
        (path for path in root.glob("*-autonomous-loop") if path.is_dir() and not path.name.startswith(".")),
        key=lambda path: path.name,
        reverse=True,
    )


def need_intake_dirs(repo: Path) -> list[Path]:
    root = repo / "task-runs"
    if not root.exists():
        return []
    return sorted(
        (path for path in root.glob("*-need-intake") if path.is_dir() and not path.name.startswith(".")),
        key=lambda path: path.name,
        reverse=True,
    )


def task_run_dirs(repo: Path, suffix: str | None = None) -> list[Path]:
    root = repo / "task-runs"
    if not root.exists():
        return []
    dirs = [path for path in root.glob("*") if path.is_dir() and not path.name.startswith(".")]
    if suffix:
        dirs = [path for path in dirs if path.name.endswith(suffix)]
    return sorted(dirs, key=lambda path: path.name, reverse=True)


def validate_task_run_dir(repo: Path, rel_path: str, suffix: str) -> Path:
    path = safe_join(repo, rel_path)
    path_rel = rel(repo, path)
    if not path.exists() or not path.is_dir():
        raise ValueError("run directory not found")
    if is_hidden_or_git(path, repo) or not path_rel.startswith("task-runs/") or not path.name.endswith(suffix):
        raise ValueError(f"only task-runs/*{suffix} directories are allowed")
    return path


def optional_text(path: Path, limit: int = 8000) -> str:
    if not path.exists() or not path.is_file():
        return ""
    if path.stat().st_size > limit:
        return read_text_file(path)[:limit] + "\n... truncated ..."
    return read_text_file(path)


def tail_lines(text: str, count: int = 40) -> str:
    lines = text.splitlines()
    return "\n".join(lines[-count:]) if len(lines) > count else text


def latest_event(run_dir: Path) -> str:
    events = optional_text(run_dir / "events.log")
    if not events.strip():
        return "None"
    return events.splitlines()[-1]


def auto_loop_status(run_dir: Path) -> str:
    if (run_dir / "stop-request.md").exists():
        return "stopped"
    if (run_dir / "errors.md").exists():
        text = optional_text(run_dir / "errors.md").lower()
        if "codex exited" in text:
            return "codex_failed"
        if "test command failed" in text:
            return "tests_failed"
        if "blocker" in text:
            return "blocked"
        return "error"
    if (run_dir / "loop-state-update.md").exists():
        return "advanced"
    if (run_dir / "codex-exit-code.txt").exists():
        code = optional_text(run_dir / "codex-exit-code.txt").strip()
        if code == "0":
            return "waiting_for_decision"
        return "codex_failed"
    state = optional_text(run_dir / "auto-loop-state.md")
    draft = optional_text(run_dir / "review-draft.md")
    combined = f"{state}\n{draft}".lower()
    if "codex_completed" in combined:
        return "codex_completed"
    if "human action required" in combined:
        return "waiting_for_decision"
    if "decision: pending" in combined or "\npending\n" in combined:
        return "waiting_for_decision"
    if "ready_for_advance" in combined:
        return "ready_for_advance"
    return "dry_run_ready"


def auto_loop_field(run_dir: Path, labels: list[str]) -> str:
    return field_value(optional_text(run_dir / "auto-loop-state.md"), labels)


def auto_loop_file_value(run_dir: Path, filename: str) -> str:
    value = optional_text(run_dir / filename).strip()
    return value if value else "not run"


def human_action_required_for_auto_loop(run_dir: Path) -> bool:
    status = auto_loop_status(run_dir)
    return status in {"waiting_for_decision", "codex_failed", "tests_failed", "stopped", "blocked", "error"}


def autonomous_loop_status(run_dir: Path) -> str:
    state = optional_text(run_dir / "autonomous-loop-state.md")
    value = field_value(state, ["status"])
    if value != "None":
        return value
    if (run_dir / "errors.md").exists():
        return "error"
    if (run_dir / "summary.md").exists():
        return "completed"
    return "unknown"


def autonomous_loop_field(run_dir: Path, labels: list[str]) -> str:
    return field_value(optional_text(run_dir / "autonomous-loop-state.md"), labels)


def autonomous_latest_cycle(run_dir: Path) -> Path | None:
    cycles = sorted(path for path in run_dir.glob("cycle-*") if path.is_dir())
    return cycles[-1] if cycles else None


def autonomous_cycle_count(run_dir: Path) -> int:
    return len([path for path in run_dir.glob("cycle-*") if path.is_dir()])


def human_action_required_for_autonomous_loop(run_dir: Path) -> bool:
    value = autonomous_loop_field(run_dir, ["human action required"])
    if value.lower() in {"yes", "true"}:
        return True
    return autonomous_loop_status(run_dir) in {"blocked", "error", "tests_failed", "codex_failed", "waiting_for_decision", "stopped"}


TOKEN_PATTERNS = {
    "total": re.compile(r"(?:total(?:[_ -]?tokens)?|tokens)[=:]?\s*([0-9][0-9,]*)", re.IGNORECASE),
    "input": re.compile(r"(?:input|prompt)(?:[_ -]?tokens)?[=:]?\s*([0-9][0-9,]*)", re.IGNORECASE),
    "output": re.compile(r"(?:output|completion)(?:[_ -]?tokens)?[=:]?\s*([0-9][0-9,]*)", re.IGNORECASE),
    "reasoning": re.compile(r"reasoning(?:[_ -]?tokens)?[=:]?\s*([0-9][0-9,]*)", re.IGNORECASE),
    "cached": re.compile(r"cached(?:[_ -]?tokens)?[=:]?\s*([0-9][0-9,]*)", re.IGNORECASE),
}


def parse_token_usage(text: str) -> dict[str, int]:
    if "token" not in text.lower() and "reasoning" not in text.lower() and "cached" not in text.lower():
        return {}
    usage: dict[str, int] = {}
    for key, pattern in TOKEN_PATTERNS.items():
        matches = pattern.findall(text)
        if matches:
            try:
                usage[key] = max(int(match.replace(",", "")) for match in matches)
            except ValueError:
                continue
    return usage


def token_candidate_files(repo: Path) -> list[Path]:
    root = repo / "task-runs"
    if not root.exists():
        return []
    candidates = []
    wanted_suffixes = {".txt", ".md", ".log"}
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in wanted_suffixes:
            continue
        if is_hidden_or_git(path, repo) or is_secret_like(path):
            continue
        name = path.name.lower()
        parent = path.parent.name.lower()
        if any(part in name or part in parent for part in ("stdout", "stderr", "evidence", "summary", "state", "review", "codex", "token")):
            if path.stat().st_size <= MAX_TEXT_BYTES:
                candidates.append(path)
    return sorted(candidates, key=lambda item: rel(repo, item))


def collect_token_usage(repo: Path) -> tuple[list[dict[str, object]], list[Path]]:
    rows: list[dict[str, object]] = []
    without_data: list[Path] = []
    for path in token_candidate_files(repo):
        text = optional_text(path, MAX_TEXT_BYTES)
        usage = parse_token_usage(text)
        if usage:
            rows.append({"path": path, "usage": usage})
        else:
            without_data.append(path)
    return rows, without_data


def page(title: str, body: str) -> bytes:
    nav = "".join(
        [
            route_link("/", "Dashboard"),
            route_link("/needs", "Needs"),
            route_link("/loop-dashboard", "Loop Dashboard"),
            route_link("/auto-loop", "Auto Loop"),
            route_link("/autonomous-loop", "Autonomous"),
            route_link("/iterations", "Iterations"),
            route_link("/tokens", "Tokens"),
            route_link("/runs", "Runs"),
            route_link("/reviews", "Reviews"),
            route_link("/logics", "Logics"),
            route_link("/debug", "Debug"),
        ]
    )
    css = """
    body { margin: 0; font-family: system-ui, -apple-system, Segoe UI, sans-serif; color: #202124; background: #f7f8fa; }
    header { background: #1f2933; color: white; padding: 16px 24px; }
    header h1 { margin: 0 0 10px; font-size: 22px; }
    nav a { color: #dbeafe; margin-right: 16px; text-decoration: none; font-weight: 600; }
    main { max-width: 1180px; margin: 0 auto; padding: 24px; }
    h2 { margin-top: 0; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 12px; }
    .card, section { background: white; border: 1px solid #d9dee7; border-radius: 8px; padding: 16px; margin-bottom: 16px; }
    .metric { font-size: 28px; font-weight: 700; }
    .muted { color: #667085; }
    .warn { background: #fff7ed; border: 1px solid #fed7aa; color: #7c2d12; padding: 12px; border-radius: 8px; margin-bottom: 12px; }
    .ok { background: #ecfdf3; border: 1px solid #bbf7d0; color: #14532d; padding: 12px; border-radius: 8px; margin-bottom: 12px; }
    table { width: 100%; border-collapse: collapse; background: white; }
    th, td { border-bottom: 1px solid #e5e7eb; padding: 9px 8px; text-align: left; vertical-align: top; }
    th { color: #475467; font-size: 13px; }
    pre { background: #111827; color: #f9fafb; padding: 14px; border-radius: 8px; overflow: auto; white-space: pre-wrap; }
    code { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
    a { color: #175cd3; }
    ul { padding-left: 20px; }
    """
    html_doc = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{esc(title)} - Orchestia</title>
  <style>{css}</style>
</head>
<body>
  <header><h1>Orchestia local cockpit</h1><nav>{nav}</nav></header>
  <main>{body}</main>
</body>
</html>"""
    return html_doc.encode("utf-8")


class OrchestiaHandler(BaseHTTPRequestHandler):
    repo: Path = Path.cwd()

    def log_message(self, fmt: str, *args: object) -> None:
        print(f"{self.address_string()} - {fmt % args}")

    def do_POST(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)
        routes = {
            "/needs/create": self.create_need,
            "/actions/autonomous-loop-instruct": self.autonomous_loop_instruct_action,
            "/actions/autonomous-loop-stop": self.autonomous_loop_stop_action,
        }
        handler = routes.get(parsed.path)
        if handler is None:
            self.send_error(404, "Action not found")
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self.send_error(400, "Invalid content length")
            return
        if length > MAX_POST_BYTES:
            self.send_error(413, "POST body too large")
            return
        raw = self.rfile.read(length).decode("utf-8", errors="replace")
        data = parse_qs(raw, keep_blank_values=True)
        try:
            content = handler(data)
        except Exception as exc:  # noqa: BLE001 - return safe error page.
            content = page("Action error", f"<section><h2>Action error</h2><div class=\"warn\">{esc(exc)}</div></section>")
            self.send_response(400)
        else:
            self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(content)

    def do_GET(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)
        query = parse_qs(parsed.query)
        routes = {
            "/": self.dashboard,
            "/needs": self.needs,
            "/needs/new": self.new_need,
            "/need-intake": lambda: self.need_intake_detail(query),
            "/loops": self.loops,
            "/loop-dashboard": self.loop_dashboard,
            "/loop": lambda: self.loop_detail(query),
            "/auto-loop": self.auto_loop,
            "/auto-loop-run": lambda: self.auto_loop_run(query),
            "/autonomous-loop": self.autonomous_loop,
            "/autonomous-loop-run": lambda: self.autonomous_loop_run(query),
            "/iterations": self.iterations,
            "/iteration": lambda: self.iteration_detail(query),
            "/tokens": self.tokens,
            "/runs": self.runs,
            "/run": lambda: self.run_detail(query),
            "/file": lambda: self.file_view(query),
            "/logics": self.logics,
            "/reviews": self.reviews,
            "/debug": self.debug,
        }
        handler = routes.get(parsed.path)
        if handler is None:
            self.send_error(404, "Page not found")
            return
        try:
            content = handler()
        except Exception as exc:  # noqa: BLE001 - return safe error page.
            content = page("Error", f"<section><h2>Error</h2><pre>{esc(exc)}</pre></section>")
            self.send_response(500)
        else:
            self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(content)

    def create_need(self, data: dict[str, list[str]]) -> bytes:
        title = first_value(data, "title", 300)
        if not title:
            raise ValueError("title is required")
        intake_dir = self.repo / "task-runs" / f"{utc_timestamp()}-need-intake"
        intake_dir.mkdir(parents=True, exist_ok=False)
        intake_file = intake_dir / "need-intake.md"
        content = f"""# Need Intake Draft

## Metadata

- Source: cockpit
- Created: {utc_iso()}
- Draft path: `{rel(self.repo, intake_file)}`

## Title

{title}

## Description

{first_value(data, "description")}

## Constraints

{first_value(data, "constraints")}

## Non-Goals

{first_value(data, "non_goals")}

## Preferred Project Path

{first_value(data, "preferred_project_path", 1000)}

## Notes

{first_value(data, "notes")}

## Suggested Next Step

Review this draft, then create final Logics records through the normal planning workflow. This cockpit action intentionally does not write to `logics/`.
"""
        intake_file.write_text(content, encoding="utf-8")
        path_rel = rel(self.repo, intake_file)
        body = f"""
<section><h2>Need intake draft created</h2>
<div class="ok">Draft written under task-runs. No Logics records were created.</div>
<p><strong>Draft:</strong> <a href="/need-intake?path={quote(path_rel)}">{esc(path_rel)}</a></p>
<h3>Suggested next step</h3>
<pre>{esc('Review the draft, then create IN/PN/REQ/BL/TASK records through the documented Logics workflow.')}</pre>
</section>
"""
        return page("Need intake created", body)

    def autonomous_loop_instruct_action(self, data: dict[str, list[str]]) -> bytes:
        run_rel = first_value(data, "run_path", 1000)
        instruction = first_value(data, "instruction", 8000)
        if not instruction:
            raise ValueError("instruction text is required")
        run_dir = validate_task_run_dir(self.repo, run_rel, "-autonomous-loop")
        target = run_dir / "instructions.md"
        with target.open("a", encoding="utf-8") as handle:
            handle.write(f"\n## {utc_iso()}\n{instruction}\n")
        events = run_dir / "events.log"
        with events.open("a", encoding="utf-8") as handle:
            handle.write(f"{utc_iso()} cockpit instruction appended\n")
        return self.action_result("Instruction appended", target, "No command was executed and no project workspace was modified.")

    def autonomous_loop_stop_action(self, data: dict[str, list[str]]) -> bytes:
        run_rel = first_value(data, "run_path", 1000)
        reason = first_value(data, "stop_reason", 8000)
        if not reason:
            raise ValueError("stop reason is required")
        run_dir = validate_task_run_dir(self.repo, run_rel, "-autonomous-loop")
        target = run_dir / "stop-request.md"
        with target.open("a", encoding="utf-8") as handle:
            handle.write(f"\n## {utc_iso()}\n{reason}\n")
        events = run_dir / "events.log"
        with events.open("a", encoding="utf-8") as handle:
            handle.write(f"{utc_iso()} cockpit stop requested\n")
        return self.action_result("Stop request recorded", target, "No command was executed and no project workspace was modified.")

    def action_result(self, title: str, target: Path, note: str) -> bytes:
        target_rel = rel(self.repo, target)
        body = f"""
<section><h2>{esc(title)}</h2>
<div class="ok">{esc(note)}</div>
<p><strong>File:</strong> {file_link(self.repo, target, target_rel)}</p>
<p>{route_link('/autonomous-loop', 'Back to autonomous-loop runs')}</p>
</section>
"""
        return page(title, body)

    def dashboard(self) -> bytes:
        repo = self.repo
        branch = run_git(repo, ["branch", "--show-current"]) or "unknown"
        status = run_git(repo, ["status", "--short"])
        latest = run_git(repo, ["log", "--oneline", "--max-count=1"]) or "None"
        warnings = []
        if is_under_mnt_c(repo):
            warnings.append("Repository is under /mnt/c.")
        if status:
            warnings.append("Working tree is not clean.")
        for folder in EXPECTED_FOLDERS:
            if not (repo / folder).exists():
                warnings.append(f"Missing expected folder: {folder}")

        cards = [
            ("Initial needs", count_files(repo, "logics/initial-needs")),
            ("Primary needs", count_files(repo, "logics/primary-needs")),
            ("Loop states", count_files(repo, "logics/loop-states")),
            ("Requests", count_files(repo, "logics/requests")),
            ("Backlog items", count_files(repo, "logics/backlog")),
            ("Tasks", count_files(repo, "logics/tasks")),
            ("Reviews", count_files(repo, "logics/reviews")),
            ("task-runs", len([p for p in (repo / "task-runs").glob("*") if p.is_dir()]) if (repo / "task-runs").exists() else 0),
        ]
        auto_runs = auto_loop_dirs(repo)
        latest_auto = auto_runs[0] if auto_runs else None
        if latest_auto and human_action_required_for_auto_loop(latest_auto):
            warnings.append(f"Human action required in latest auto-loop run: {latest_auto.name}")
        autonomous_runs = autonomous_loop_dirs(repo)
        latest_autonomous = autonomous_runs[0] if autonomous_runs else None
        if latest_autonomous and human_action_required_for_autonomous_loop(latest_autonomous):
            warnings.append(f"Human action required in latest autonomous-loop run: {latest_autonomous.name}")
        latest_auto_html = "<p>No auto-loop runs found.</p>"
        if latest_auto:
            latest_rel = rel(repo, latest_auto)
            codex_executed = "yes" if (latest_auto / "codex-exit-code.txt").exists() else "no"
            latest_auto_html = (
                f'<p><strong>Latest auto-loop:</strong> '
                f'<a href="/auto-loop-run?path={quote(latest_rel)}">{esc(latest_auto.name)}</a></p>'
                f'<p><strong>Status:</strong> {esc(auto_loop_status(latest_auto))}</p>'
                f'<p><strong>Codex executed:</strong> {esc(codex_executed)}</p>'
                f'<p><strong>Codex sandbox mode:</strong> {esc(auto_loop_file_value(latest_auto, "codex-sandbox-mode.txt"))}</p>'
                f'<p><strong>Codex exit code:</strong> {esc(auto_loop_file_value(latest_auto, "codex-exit-code.txt"))}</p>'
                f'<p><strong>Test exit code:</strong> {esc(auto_loop_file_value(latest_auto, "test-exit-code.txt"))}</p>'
                f'<p><strong>Latest event:</strong> {esc(latest_event(latest_auto))}</p>'
            )
        latest_autonomous_html = "<p>No autonomous-loop runs found.</p>"
        if latest_autonomous:
            latest_autonomous_rel = rel(repo, latest_autonomous)
            latest_cycle = autonomous_latest_cycle(latest_autonomous)
            latest_autonomous_html = (
                f'<p><strong>Latest autonomous-loop:</strong> '
                f'<a href="/autonomous-loop-run?path={quote(latest_autonomous_rel)}">{esc(latest_autonomous.name)}</a></p>'
                f'<p><strong>Status:</strong> {esc(autonomous_loop_status(latest_autonomous))}</p>'
                f'<p><strong>Cycles:</strong> {esc(autonomous_loop_field(latest_autonomous, ["cycles completed"]))}</p>'
                f'<p><strong>Latest cycle:</strong> {esc(latest_cycle.name if latest_cycle else "None")}</p>'
                f'<p><strong>Latest decision:</strong> {esc(autonomous_loop_field(latest_autonomous, ["latest decision"]))}</p>'
                f'<p><strong>Human action required:</strong> {esc(autonomous_loop_field(latest_autonomous, ["human action required"]))}</p>'
            )
        warning_html = "".join(f'<div class="warn">{esc(item)}</div>' for item in warnings) or '<div class="ok">No dashboard warnings.</div>'
        card_html = "".join(f'<div class="card"><div class="muted">{esc(label)}</div><div class="metric">{value}</div></div>' for label, value in cards)
        body = f"""
<section>
  <h2>Dashboard</h2>
  {warning_html}
  <p><strong>Repository:</strong> <code>{esc(repo)}</code></p>
  <p><strong>Branch:</strong> <code>{esc(branch)}</code></p>
  <p><strong>Latest commit:</strong> <code>{esc(latest)}</code></p>
  <p><strong>Git status:</strong> {esc(status or 'clean')}</p>
</section>
<div class="grid">{card_html}</div>
<section>
  <h2>Auto-loop</h2>
  {latest_auto_html}
  <p>{route_link('/auto-loop', 'View auto-loop runs')}</p>
</section>
<section>
  <h2>Autonomous-loop</h2>
  {latest_autonomous_html}
  <p>{route_link('/autonomous-loop', 'View autonomous-loop runs')}</p>
</section>
<section>
  <h2>Main sections</h2>
  <ul>
    <li>{route_link('/needs', 'Needs')}</li>
    <li>{route_link('/loop-dashboard', 'Loop Dashboard')}</li>
    <li>{route_link('/loops', 'Loop states')}</li>
    <li>{route_link('/auto-loop', 'Auto-loop runs')}</li>
    <li>{route_link('/autonomous-loop', 'Autonomous-loop runs')}</li>
    <li>{route_link('/iterations', 'Iterations')}</li>
    <li>{route_link('/tokens', 'Tokens')}</li>
    <li>{route_link('/runs', 'task-runs reports')}</li>
    <li>{route_link('/logics', 'Logics files')}</li>
    <li>{route_link('/reviews', 'Reviews')}</li>
    <li>{route_link('/debug', 'Debug')}</li>
  </ul>
</section>
"""
        return page("Dashboard", body)

    def needs(self) -> bytes:
        intake_rows = []
        for path in need_intake_dirs(self.repo):
            intake_file = path / "need-intake.md"
            title = "Untitled"
            if intake_file.exists():
                title = field_value(optional_text(intake_file), ["title"])
                if title == "None":
                    title = path.name
            path_rel = rel(self.repo, intake_file)
            intake_rows.append(
                "<tr>"
                f'<td><a href="/need-intake?path={quote(path_rel)}">{esc(title)}</a></td>'
                f"<td>{esc(path.name)}</td>"
                "<td>draft</td>"
                "</tr>"
            )
        initial_rows = []
        for path in list_markdown(self.repo / "logics/initial-needs"):
            text = read_text_file(path)
            initial_rows.append(
                "<tr>"
                f"<td>{file_link(self.repo, path)}</td>"
                f"<td>{esc(field_value(text, ['status']))}</td>"
                "<td>Logics</td>"
                "</tr>"
            )
        body = f"""
<section><h2>Needs</h2>
<p>{route_link('/needs/new', 'Create draft need intake')}</p>
</section>
<section><h2>Draft need intakes</h2>
<table><thead><tr><th>Title</th><th>Directory</th><th>Type</th></tr></thead><tbody>{"".join(intake_rows) or '<tr><td colspan="3">No intake drafts found.</td></tr>'}</tbody></table>
</section>
<section><h2>Initial needs</h2>
<table><thead><tr><th>File</th><th>Status</th><th>Type</th></tr></thead><tbody>{"".join(initial_rows) or '<tr><td colspan="3">No initial needs found.</td></tr>'}</tbody></table>
</section>
"""
        return page("Needs", body)

    def new_need(self) -> bytes:
        body = """
<section><h2>New Need Intake</h2>
<p class="muted">This creates a draft under task-runs only. It does not create final Logics records.</p>
<form method="post" action="/needs/create">
  <p><label>Initial need title<br><input name="title" required style="width:100%;max-width:720px"></label></p>
  <p><label>Description<br><textarea name="description" rows="7" style="width:100%;max-width:900px"></textarea></label></p>
  <p><label>Constraints<br><textarea name="constraints" rows="4" style="width:100%;max-width:900px"></textarea></label></p>
  <p><label>Non-goals<br><textarea name="non_goals" rows="4" style="width:100%;max-width:900px"></textarea></label></p>
  <p><label>Preferred project path<br><input name="preferred_project_path" style="width:100%;max-width:720px"></label></p>
  <p><label>Notes<br><textarea name="notes" rows="4" style="width:100%;max-width:900px"></textarea></label></p>
  <p><button type="submit">Create draft intake</button></p>
</form>
</section>
"""
        return page("New Need", body)

    def need_intake_detail(self, query: dict[str, list[str]]) -> bytes:
        path = safe_join(self.repo, query.get("path", [""])[0])
        path_rel = rel(self.repo, path)
        if not path_rel.startswith("task-runs/") or not path_rel.endswith("/need-intake.md"):
            return page("Need intake blocked", '<section><div class="warn">Only task-runs/*-need-intake/need-intake.md files are shown here.</div></section>')
        allowed, reason = safe_file_allowed(path, self.repo)
        if not allowed:
            return page("Need intake blocked", f'<section><div class="warn">{esc(reason)}</div></section>')
        text = read_text_file(path)
        body = f"""
<section><h2>{esc(path_rel)}</h2>
<p>{route_link('/needs', 'Back to needs')}</p>
<pre>{esc(text)}</pre>
</section>
<section><h2>Suggested next step</h2>
<pre>{esc('Create final Logics records from this draft only after human review.')}</pre>
</section>
"""
        return page("Need Intake", body)

    def loop_dashboard(self) -> bytes:
        rows = []
        for path in list_markdown(self.repo / "logics/loop-states"):
            text = read_text_file(path)
            fields = loop_fields(text)
            status = field_value(text, ["status"])
            latest_auto = auto_loop_dirs(self.repo)[0].name if auto_loop_dirs(self.repo) else "None"
            latest_autonomous = autonomous_loop_dirs(self.repo)[0].name if autonomous_loop_dirs(self.repo) else "None"
            if "complete" in status.lower() or "complete" in fields["stop_condition"].lower():
                human_required = "no"
            else:
                human_required = "yes" if fields["next_action"] != "None" else "no"
            rows.append(
                "<tr>"
                f"<td>{file_link(self.repo, path)}</td>"
                f"<td>{esc(status)}</td>"
                f"<td>{esc(fields['current_primary_need'])}</td>"
                f"<td>{esc(fields['current_task'])}</td>"
                f"<td>{esc(fields['next_action'])}</td>"
                f"<td>{esc(fields['stop_condition'])}</td>"
                f"<td>{esc(fields['last_review'])}</td>"
                f"<td>{esc(latest_auto)}</td>"
                f"<td>{esc(latest_autonomous)}</td>"
                f"<td>{esc(human_required)}</td>"
                "</tr>"
            )
        body = f"""
<section><h2>Loop Dashboard</h2>
<table><thead><tr><th>Loop state</th><th>Status</th><th>Primary need</th><th>Task</th><th>Next action</th><th>Stop condition</th><th>Last review</th><th>Latest auto-loop</th><th>Latest autonomous-loop</th><th>Human action</th></tr></thead><tbody>{"".join(rows) or '<tr><td colspan="10">No Loop states found.</td></tr>'}</tbody></table>
</section>
"""
        return page("Loop Dashboard", body)

    def loops(self) -> bytes:
        repo = self.repo
        rows = []
        for path in list_markdown(repo / "logics/loop-states"):
            text = read_text_file(path)
            fields = loop_fields(text)
            path_rel = rel(repo, path)
            rows.append(
                "<tr>"
                f'<td><a href="/loop?path={quote(path_rel)}">{esc(path.name)}</a></td>'
                f"<td>{esc(fields['current_primary_need'])}</td>"
                f"<td>{esc(fields['current_task'])}</td>"
                f"<td>{esc(fields['decision'])}</td>"
                "</tr>"
            )
        table = "".join(rows) or '<tr><td colspan="4">No Loop state files found.</td></tr>'
        body = f"""
<section><h2>Loop states</h2>
<table><thead><tr><th>File</th><th>Current primary need</th><th>Current task</th><th>Decision</th></tr></thead><tbody>{table}</tbody></table>
</section>
"""
        return page("Loops", body)

    def loop_detail(self, query: dict[str, list[str]]) -> bytes:
        path = safe_join(self.repo, query.get("path", [""])[0])
        allowed, reason = safe_file_allowed(path, self.repo)
        if not allowed:
            return page("Loop blocked", f'<section><h2>Loop unavailable</h2><div class="warn">{esc(reason)}</div></section>')
        text = read_text_file(path)
        fields = loop_fields(text)
        path_rel = rel(self.repo, path)
        status_cmd = f"bash scripts/orchestia_loop.sh status {path_rel}"
        next_cmd = f"bash scripts/orchestia_loop.sh next {path_rel}"
        git_flow_template = (
            f"bash scripts/orchestia_loop.sh git-flow {path_rel} "
            "--workspace ~/ai-workspaces/example-project --remote origin "
            "--source-branch feature/example --target-branch integration "
            '--test "python3 -m unittest discover -s tests"'
        )
        body = f"""
<section><h2>{esc(path.name)}</h2>
<p><strong>Current primary need:</strong> {esc(fields['current_primary_need'])}</p>
<p><strong>Current task:</strong> {esc(fields['current_task'])}</p>
<p><strong>Decision:</strong> {esc(fields['decision'])}</p>
<p><strong>Next action:</strong> {esc(fields['next_action'])}</p>
<p><strong>Stop condition:</strong> {esc(fields['stop_condition'])}</p>
</section>
<section><h2>Suggested CLI commands</h2>
<pre>{esc(status_cmd)}
{esc(next_cmd)}
{esc(git_flow_template)}</pre>
</section>
<section><h2>Content</h2><pre>{esc(text)}</pre></section>
"""
        return page("Loop detail", body)

    def auto_loop(self) -> bytes:
        rows = []
        for path in auto_loop_dirs(self.repo):
            path_rel = rel(self.repo, path)
            task = auto_loop_field(path, ["current task"])
            decision_value = auto_loop_field(path, ["decision"])
            human_action = "yes" if human_action_required_for_auto_loop(path) else "no"
            rows.append(
                "<tr>"
                f'<td><a href="/auto-loop-run?path={quote(path_rel)}">{esc(path.name)}</a></td>'
                f"<td>{esc(auto_loop_status(path))}</td>"
                f"<td>{esc(auto_loop_file_value(path, 'codex-exit-code.txt'))}</td>"
                f"<td>{esc(auto_loop_file_value(path, 'test-exit-code.txt'))}</td>"
                f"<td>{esc(task)}</td>"
                f"<td>{esc(decision_value)}</td>"
                f"<td>{esc(human_action)}</td>"
                "</tr>"
            )
        table = "".join(rows) or '<tr><td colspan="7">No auto-loop runs found.</td></tr>'
        body = f"""
<section><h2>Auto-loop runs</h2>
<table><thead><tr><th>Run</th><th>Status</th><th>Codex exit</th><th>Test exit</th><th>Active task</th><th>Decision</th><th>Human action required</th></tr></thead><tbody>{table}</tbody></table>
</section>
"""
        return page("Auto Loop", body)

    def auto_loop_run(self, query: dict[str, list[str]]) -> bytes:
        try:
            path = safe_join(self.repo, query.get("path", [""])[0])
        except ValueError as exc:
            return page("Auto-loop blocked", f'<section><div class="warn">{esc(exc)}</div></section>')
        if not path.exists() or not path.is_dir():
            return page("Auto-loop missing", '<section><h2>Auto-loop run not found</h2></section>')
        path_rel = rel(self.repo, path)
        if not path_rel.startswith("task-runs/") or not path.name.endswith("-auto-loop"):
            return page("Auto-loop blocked", '<section><div class="warn">Only task-runs/*-auto-loop directories are shown here.</div></section>')

        status = auto_loop_status(path)
        action = '<div class="warn">Human action required.</div>' if human_action_required_for_auto_loop(path) else '<div class="ok">No immediate human action detected.</div>'
        status_cmd = f"bash scripts/orchestia_loop.sh auto-loop-status {path_rel}"
        instruct_cmd = f'bash scripts/orchestia_loop.sh auto-loop-instruct {path_rel} "Add human instruction here."'
        stop_cmd = f'bash scripts/orchestia_loop.sh auto-loop-stop {path_rel} "Stop reason here."'
        finalize_cmd = 'bash scripts/orchestia_loop.sh finalize-review --draft task-runs/example-auto-loop/review-draft.md --review-id REVIEW-XXXX --review-title "Auto-loop review" --reviewed-task TASK-XXXX --decision accept'
        advance_cmd = 'bash scripts/orchestia_loop.sh auto-loop logics/loop-states/LS-XXXX.md --workspace ~/ai-workspaces/example --max-steps 1 --decision accept --advance --last-review logics/reviews/REVIEW-XXXX.md --next-action "continue" --stop-condition "pending next step"'

        def section(name: str, filename: str, lines: int = 40) -> str:
            target = path / filename
            text = optional_text(target)
            if not text:
                return f"<section><h2>{esc(name)}</h2><p class=\"muted\">Not present.</p></section>"
            link = file_link(self.repo, target, "open full file")
            return f"<section><h2>{esc(name)}</h2><p>{link}</p><pre>{esc(tail_lines(text, lines))}</pre></section>"

        body = f"""
<section><h2>{esc(path.name)}</h2>
{action}
<p><strong>Status:</strong> {esc(status)}</p>
<p><strong>Mode:</strong> {esc(auto_loop_field(path, ['mode']))}</p>
<p><strong>Active task:</strong> {esc(auto_loop_field(path, ['current task']))}</p>
<p><strong>Prepared prompt:</strong> {esc(auto_loop_field(path, ['prepared prompt path', 'prepared codex prompt']))}</p>
<p><strong>Codex executed:</strong> {esc(auto_loop_field(path, ['codex executed']))}</p>
<p><strong>Codex sandbox mode:</strong> {esc(auto_loop_file_value(path, 'codex-sandbox-mode.txt'))}</p>
<p><strong>Codex exit code:</strong> {esc(auto_loop_file_value(path, 'codex-exit-code.txt'))}</p>
<p><strong>Test exit code:</strong> {esc(auto_loop_file_value(path, 'test-exit-code.txt'))}</p>
<p><strong>Decision:</strong> {esc(auto_loop_field(path, ['decision']))}</p>
<p><strong>Next action:</strong> {esc(auto_loop_field(path, ['next action']))}</p>
<p><strong>Stop condition:</strong> {esc(auto_loop_field(path, ['stop condition']))}</p>
<p><strong>Latest event:</strong> {esc(latest_event(path))}</p>
<p>{route_link('/auto-loop', 'Back to auto-loop runs')}</p>
</section>
<section><h2>Copyable CLI commands</h2>
<pre>{esc(status_cmd)}
{esc(instruct_cmd)}
{esc(stop_cmd)}
{esc(finalize_cmd)}
{esc(advance_cmd)}</pre>
<p class="muted">The cockpit does not execute these commands or modify Loop state.</p>
</section>
{section('Auto-loop state', 'auto-loop-state.md')}
{section('Events tail', 'events.log')}
{section('Errors', 'errors.md')}
{section('Codex stdout', 'codex-stdout.txt')}
{section('Codex stderr', 'codex-stderr.txt')}
{section('Workspace diff stat after', 'workspace-diff-stat-after.txt')}
{section('Test stdout', 'test-stdout.txt')}
{section('Test stderr', 'test-stderr.txt')}
{section('Instructions', 'instructions.md')}
{section('Stop request', 'stop-request.md')}
{section('Command preview', 'command-preview.md')}
{section('Review draft', 'review-draft.md')}
"""
        return page("Auto-loop run", body)

    def autonomous_loop(self) -> bytes:
        rows = []
        for path in autonomous_loop_dirs(self.repo):
            path_rel = rel(self.repo, path)
            latest_cycle = autonomous_latest_cycle(path)
            latest_error = "None"
            if (path / "errors.md").exists():
                latest_error = tail_lines(optional_text(path / "errors.md"), 8)
            rows.append(
                "<tr>"
                f'<td><a href="/autonomous-loop-run?path={quote(path_rel)}">{esc(path.name)}</a></td>'
                f"<td>{esc(autonomous_loop_status(path))}</td>"
                f"<td>{esc(autonomous_cycle_count(path))}</td>"
                f"<td>{esc(latest_cycle.name if latest_cycle else 'None')}</td>"
                f"<td>{esc(autonomous_loop_field(path, ['latest decision']))}</td>"
                f"<td>{esc('yes' if human_action_required_for_autonomous_loop(path) else 'no')}</td>"
                f"<td><pre>{esc(latest_error)}</pre></td>"
                "</tr>"
            )
        table = "".join(rows) or '<tr><td colspan="7">No autonomous-loop runs found.</td></tr>'
        body = f"""
<section><h2>Autonomous-loop runs</h2>
<table><thead><tr><th>Run</th><th>Status</th><th>Cycles</th><th>Latest cycle</th><th>Latest decision</th><th>Human action required</th><th>Latest error</th></tr></thead><tbody>{table}</tbody></table>
</section>
"""
        return page("Autonomous Loop", body)

    def autonomous_loop_run(self, query: dict[str, list[str]]) -> bytes:
        try:
            path = safe_join(self.repo, query.get("path", [""])[0])
        except ValueError as exc:
            return page("Autonomous-loop blocked", f'<section><div class="warn">{esc(exc)}</div></section>')
        if not path.exists() or not path.is_dir():
            return page("Autonomous-loop missing", '<section><h2>Autonomous-loop run not found</h2></section>')
        path_rel = rel(self.repo, path)
        if not path_rel.startswith("task-runs/") or not path.name.endswith("-autonomous-loop"):
            return page("Autonomous-loop blocked", '<section><div class="warn">Only task-runs/*-autonomous-loop directories are shown here.</div></section>')

        latest_cycle = autonomous_latest_cycle(path)
        latest_prompt = "None"
        latest_codex = "not run"
        latest_test = "not run"
        latest_decision = autonomous_loop_field(path, ["latest decision"])
        latest_error = optional_text(path / "errors.md")
        if latest_cycle:
            latest_prompt = rel(self.repo, latest_cycle / "prompt-used.md") if (latest_cycle / "prompt-used.md").exists() else "None"
            latest_codex = optional_text(latest_cycle / "codex-exit-code.txt").strip() or "not run"
            latest_test = optional_text(latest_cycle / "test-exit-code.txt").strip() or "not run"
            latest_decision = optional_text(latest_cycle / "decision.md").strip() or latest_decision
        run_token_rows = []
        for token_file in sorted(path.rglob("*")):
            if token_file.is_file() and token_file.suffix.lower() in {".txt", ".md", ".log"} and token_file.stat().st_size <= MAX_TEXT_BYTES:
                usage = parse_token_usage(optional_text(token_file, MAX_TEXT_BYTES))
                if usage:
                    usage_text = ", ".join(f"{key}={value}" for key, value in sorted(usage.items()))
                    run_token_rows.append(f"<li>{file_link(self.repo, token_file, rel(self.repo, token_file))}: {esc(usage_text)}</li>")
        token_html = "<ul>" + "".join(run_token_rows) + "</ul>" if run_token_rows else '<p class="muted">Token usage not available for this run.</p>'

        action = '<div class="warn">Human action required.</div>' if human_action_required_for_autonomous_loop(path) else '<div class="ok">No immediate human action detected.</div>'
        rerun_cmd = "bash scripts/orchestia_loop.sh autonomous-loop <loop-state> --workspace <workspace> --max-cycles 1"
        status_cmd = f"bash scripts/orchestia_loop.sh autonomous-loop-status {path_rel}"
        review_link = "None"
        if latest_cycle and (latest_cycle / "review-draft.md").exists():
            review_link = file_link(self.repo, latest_cycle / "review-draft.md", "open latest review draft")

        def section(name: str, target: Path | None, lines: int = 40) -> str:
            if target is None or not target.exists():
                return f"<section><h2>{esc(name)}</h2><p class=\"muted\">Not present.</p></section>"
            if target.is_file():
                link = file_link(self.repo, target, "open full file")
                return f"<section><h2>{esc(name)}</h2><p>{link}</p><pre>{esc(tail_lines(optional_text(target), lines))}</pre></section>"
            links = "".join(
                f"<li>{file_link(self.repo, child)}</li>"
                for child in sorted(target.iterdir())
                if child.is_file() and not child.name.startswith(".") and safe_file_allowed(child, self.repo)[0]
            )
            return f"<section><h2>{esc(name)}</h2><ul>{links or '<li>No readable cycle files.</li>'}</ul></section>"

        cycle_links = "".join(
            f"<li>{esc(cycle.name)}: {route_link('/run?path=' + quote(rel(self.repo, cycle)), 'open files')}</li>"
            for cycle in sorted(path.glob("cycle-*"))
            if cycle.is_dir()
        )

        body = f"""
<section><h2>{esc(path.name)}</h2>
{action}
<p><strong>Status:</strong> {esc(autonomous_loop_status(path))}</p>
<p><strong>Current cycle:</strong> {esc(latest_cycle.name if latest_cycle else 'None')}</p>
<p><strong>Max cycles:</strong> {esc(autonomous_loop_field(path, ['max cycles']))}</p>
<p><strong>Cycles completed:</strong> {esc(autonomous_loop_field(path, ['cycles completed']))}</p>
<p><strong>Latest decision:</strong> {esc(latest_decision)}</p>
<p><strong>Latest prompt:</strong> {esc(latest_prompt)}</p>
<p><strong>Latest Codex exit code:</strong> {esc(latest_codex)}</p>
<p><strong>Latest test exit code:</strong> {esc(latest_test)}</p>
<p><strong>Human action required:</strong> {esc(autonomous_loop_field(path, ['human action required']))}</p>
<p><strong>Latest error:</strong></p><pre>{esc(tail_lines(latest_error, 12) if latest_error else 'None')}</pre>
<p>{route_link('/autonomous-loop', 'Back to autonomous-loop runs')}</p>
</section>
<section><h2>Copyable command previews</h2>
<pre>{esc(status_cmd)}
{esc(rerun_cmd)}</pre>
<p><strong>Latest review draft:</strong> {review_link}</p>
<p class="muted">The cockpit does not execute Codex, push, merge, or modify Loop state.</p>
</section>
<section><h2>Safe controls</h2>
<form method="post" action="/actions/autonomous-loop-instruct">
  <input type="hidden" name="run_path" value="{esc(path_rel)}">
  <p><label>Instruction<br><textarea name="instruction" rows="4" style="width:100%;max-width:900px"></textarea></label></p>
  <p><button type="submit">Append instruction</button></p>
</form>
<form method="post" action="/actions/autonomous-loop-stop">
  <input type="hidden" name="run_path" value="{esc(path_rel)}">
  <p><label>Stop reason<br><textarea name="stop_reason" rows="4" style="width:100%;max-width:900px"></textarea></label></p>
  <p><button type="submit">Request stop</button></p>
</form>
<p class="muted">These actions only append files inside this autonomous-loop run directory.</p>
</section>
<section><h2>Token usage evidence</h2>
{token_html}
</section>
<section><h2>Cycles</h2><ul>{cycle_links or '<li>No cycle directories.</li>'}</ul></section>
{section('Autonomous-loop state', path / 'autonomous-loop-state.md')}
{section('Summary', path / 'summary.md')}
{section('Events tail', path / 'events.log')}
{section('Errors', path / 'errors.md')}
{section('Instructions', path / 'instructions.md')}
{section('Stop request', path / 'stop-request.md')}
{section('Latest cycle files', latest_cycle)}
"""
        return page("Autonomous-loop run", body)

    def iterations(self) -> bytes:
        items: list[tuple[str, str, Path, str, str]] = []
        for path in task_run_dirs(self.repo):
            kind = infer_run_type(path)
            status = "present"
            decision_value = "None"
            if kind == "auto-loop":
                status = auto_loop_status(path)
                decision_value = auto_loop_field(path, ["decision"])
            elif kind == "autonomous-loop":
                status = autonomous_loop_status(path)
                decision_value = autonomous_loop_field(path, ["latest decision"])
            elif (path / "evidence.md").exists():
                status = field_value(optional_text(path / "evidence.md"), ["final result"])
            items.append((path.name[:16], kind, path, status, decision_value))
        for path in list_markdown(self.repo / "logics/reviews"):
            items.append((path.name, "review", path, "recorded", review_decision(read_text_file(path))))
        for path in list_markdown(self.repo / "logics/tasks"):
            items.append((path.name, "task", path, field_value(read_text_file(path), ["status"]), "None"))
        items.sort(key=lambda item: item[0], reverse=True)
        rows = []
        for _, kind, path, status, decision_value in items[:250]:
            path_rel = rel(self.repo, path)
            href = "/iteration?path=" + quote(path_rel)
            task = "None"
            if path.is_file():
                task = field_value(read_text_file(path), ["reviewed task", "related task", "id"])
            rows.append(
                "<tr>"
                f'<td><a href="{esc(href)}">{esc(path.name)}</a></td>'
                f"<td>{esc(kind)}</td>"
                f"<td>{esc(task)}</td>"
                f"<td>{esc(decision_value)}</td>"
                f"<td>{esc(status)}</td>"
                f"<td>{esc(path_rel)}</td>"
                "</tr>"
            )
        body = f"""
<section><h2>Iteration Timeline</h2>
<p class="muted">Inferred from task-runs, reviews, and task records. Newest timestamp-like entries appear first.</p>
<table><thead><tr><th>Item</th><th>Type</th><th>Related task</th><th>Decision</th><th>Status</th><th>Evidence</th></tr></thead><tbody>{"".join(rows) or '<tr><td colspan="6">No iterations found.</td></tr>'}</tbody></table>
</section>
"""
        return page("Iterations", body)

    def iteration_detail(self, query: dict[str, list[str]]) -> bytes:
        path = safe_join(self.repo, query.get("path", [""])[0])
        path_rel = rel(self.repo, path)
        if path.is_dir():
            if not path_rel.startswith("task-runs/") or is_hidden_or_git(path, self.repo):
                return page("Iteration blocked", '<section><div class="warn">Only task-runs directories are shown here.</div></section>')
            return self.run_detail({"path": [path_rel]})
        allowed, reason = safe_file_allowed(path, self.repo)
        if not allowed:
            return page("Iteration blocked", f'<section><div class="warn">{esc(reason)}</div></section>')
        text = read_text_file(path)
        body = f"""
<section><h2>{esc(path_rel)}</h2>
<p>{route_link('/iterations', 'Back to iterations')}</p>
<pre>{esc(text)}</pre>
</section>
"""
        return page("Iteration", body)

    def tokens(self) -> bytes:
        rows, without_data = collect_token_usage(self.repo)
        totals: dict[str, int] = {}
        for row in rows:
            usage = row["usage"]
            assert isinstance(usage, dict)
            for key, value in usage.items():
                totals[key] = totals.get(key, 0) + int(value)
        total_text = ", ".join(f"{key}: {value}" for key, value in sorted(totals.items())) if totals else "not available"
        token_rows = []
        for row in rows:
            path = row["path"]
            usage = row["usage"]
            assert isinstance(path, Path)
            assert isinstance(usage, dict)
            usage_text = ", ".join(f"{key}={value}" for key, value in sorted(usage.items()))
            token_rows.append(
                "<tr>"
                f"<td>{file_link(self.repo, path, rel(self.repo, path))}</td>"
                f"<td>{esc(usage_text)}</td>"
                "</tr>"
            )
        missing_rows = "".join(f"<li>{esc(rel(self.repo, path))}</li>" for path in without_data[:100])
        body = f"""
<section><h2>Token Usage Evidence</h2>
<p><strong>Total known tokens:</strong> {esc(total_text)}</p>
<p class="muted">Totals are shown only when parseable token evidence exists in local task-runs text files. No billing APIs are called and missing usage is not invented.</p>
</section>
<section><h2>Runs with token data</h2>
<table><thead><tr><th>Evidence file</th><th>Parsed usage</th></tr></thead><tbody>{"".join(token_rows) or '<tr><td colspan="2">No token usage evidence found.</td></tr>'}</tbody></table>
</section>
<section><h2>Scanned files without token data</h2>
<ul>{missing_rows or '<li>not available</li>'}</ul>
</section>
"""
        return page("Tokens", body)

    def runs(self) -> bytes:
        root = self.repo / "task-runs"
        dirs = sorted((p for p in root.glob("*") if p.is_dir() and not p.name.startswith(".")), key=lambda p: p.name, reverse=True) if root.exists() else []
        rows = []
        for path in dirs:
            path_rel = rel(self.repo, path)
            rows.append(
                "<tr>"
                f'<td><a href="/run?path={quote(path_rel)}">{esc(path.name)}</a></td>'
                f"<td>{esc(infer_run_type(path))}</td>"
                "</tr>"
            )
        table = "".join(rows) or '<tr><td colspan="2">No task-runs directories found.</td></tr>'
        body = f'<section><h2>task-runs</h2><table><thead><tr><th>Directory</th><th>Type</th></tr></thead><tbody>{table}</tbody></table></section>'
        return page("Runs", body)

    def run_detail(self, query: dict[str, list[str]]) -> bytes:
        path = safe_join(self.repo, query.get("path", [""])[0])
        if not path.exists() or not path.is_dir():
            return page("Run missing", '<section><h2>Run not found</h2></section>')
        if is_hidden_or_git(path, self.repo) or not rel(self.repo, path).startswith("task-runs/"):
            return page("Run blocked", '<section><div class="warn">Only task-runs directories are shown here.</div></section>')
        items = []
        for child in sorted(path.iterdir()):
            if child.name.startswith("."):
                continue
            if child.is_file():
                allowed, reason = safe_file_allowed(child, self.repo)
                if allowed:
                    items.append(f"<li>{file_link(self.repo, child)} <span class=\"muted\">{child.stat().st_size} bytes</span></li>")
                else:
                    items.append(f"<li>{esc(child.name)} <span class=\"muted\">skipped: {esc(reason)}</span></li>")
        body = f'<section><h2>{esc(path.name)}</h2><p>{route_link("/runs", "Back to runs")}</p><ul>{"".join(items) or "<li>No readable files.</li>"}</ul></section>'
        return page("Run detail", body)

    def file_view(self, query: dict[str, list[str]]) -> bytes:
        try:
            path = safe_join(self.repo, query.get("path", [""])[0])
        except ValueError as exc:
            return page("File blocked", f'<section><div class="warn">{esc(exc)}</div></section>')
        allowed, reason = safe_file_allowed(path, self.repo)
        if not allowed:
            return page("File blocked", f'<section><h2>{esc(path.name)}</h2><div class="warn">{esc(reason)}</div></section>')
        text = read_text_file(path)
        body = f'<section><h2>{esc(rel(self.repo, path))}</h2><p><a href="javascript:history.back()">Back</a></p><pre>{esc(text)}</pre></section>'
        return page("File", body)

    def logics(self) -> bytes:
        sections = []
        for title, folder in LOGICS_GROUPS:
            files = list_markdown(self.repo / folder)
            links = "".join(f"<li>{file_link(self.repo, path)}</li>" for path in files) or "<li>No files.</li>"
            sections.append(f"<section><h2>{esc(title)}</h2><ul>{links}</ul></section>")
        return page("Logics", "".join(sections))

    def reviews(self) -> bytes:
        rows = []
        for path in list_markdown(self.repo / "logics/reviews"):
            text = read_text_file(path)
            rows.append(
                "<tr>"
                f"<td>{file_link(self.repo, path)}</td>"
                f"<td>{esc(review_decision(text))}</td>"
                "</tr>"
            )
        table = "".join(rows) or '<tr><td colspan="2">No reviews found.</td></tr>'
        body = f'<section><h2>Reviews</h2><table><thead><tr><th>File</th><th>Decision</th></tr></thead><tbody>{table}</tbody></table></section>'
        return page("Reviews", body)

    def debug(self) -> bytes:
        repo = self.repo
        branch = run_git(repo, ["branch", "--show-current"]) or "unknown"
        status = run_git(repo, ["status", "--short"])
        commits = run_git(repo, ["log", "--oneline", "--max-count=5"])
        folder_checks = "".join(f"<li>{esc(folder)}: {'yes' if (repo / folder).exists() else 'missing'}</li>" for folder in EXPECTED_FOLDERS)
        script_checks = "".join(f"<li>{esc(script)}: {'yes' if (repo / script).exists() else 'missing'}</li>" for script in EXPECTED_SCRIPTS)
        warnings = []
        if status:
            warnings.append("Working tree is dirty.")
        if is_under_mnt_c(repo):
            warnings.append("Repository is under /mnt/c.")
        warning_html = "".join(f'<div class="warn">{esc(item)}</div>' for item in warnings) or '<div class="ok">No debug warnings.</div>'
        body = f"""
<section><h2>Debug</h2>
{warning_html}
<p><strong>Python:</strong> <code>{esc(sys.version.split()[0])}</code></p>
<p><strong>Repo:</strong> <code>{esc(repo)}</code></p>
<p><strong>Branch:</strong> <code>{esc(branch)}</code></p>
<h3>Git status --short</h3><pre>{esc(status or 'clean')}</pre>
<h3>Latest commits</h3><pre>{esc(commits or 'None')}</pre>
<h3>Expected folders</h3><ul>{folder_checks}</ul>
<h3>Script checks</h3><ul>{script_checks}</ul>
</section>
"""
        return page("Debug", body)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Serve the local read-only Orchestia cockpit.")
    parser.add_argument("--host", default=DEFAULT_HOST, help="Host to bind, default: 127.0.0.1")
    parser.add_argument("--port", default=DEFAULT_PORT, type=int, help="Port to bind, default: 8765")
    parser.add_argument("--repo", default=".", help="Repository root to inspect, default: current directory")
    parser.add_argument("--allow-mnt-c", action="store_true", help="Allow serving a repository under /mnt/c")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo = Path(args.repo).resolve()
    if is_under_mnt_c(repo) and not args.allow_mnt_c:
        print("error: refusing to serve a repository under /mnt/c without --allow-mnt-c", file=sys.stderr)
        return 2
    if not (repo / "AGENTS.md").exists():
        print("error: AGENTS.md not found; provide the Orchestia repo with --repo", file=sys.stderr)
        return 2
    if args.host not in {"127.0.0.1", "localhost"}:
        print("warning: binding outside localhost; this read-only cockpit is intended for local use only", file=sys.stderr)

    OrchestiaHandler.repo = repo
    server = ThreadingHTTPServer((args.host, args.port), OrchestiaHandler)
    url = f"http://{args.host}:{args.port}"
    print(f"Serving Orchestia local cockpit at {url}")
    print(f"Repository: {repo}")
    print("Press Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping.")
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
