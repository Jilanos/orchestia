#!/usr/bin/env python3
"""Local read-only HTML cockpit for Orchestia."""

from __future__ import annotations

import argparse
import html
import os
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import subprocess
import sys
from urllib.parse import parse_qs, quote, unquote, urlparse


DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 8765
MAX_TEXT_BYTES = 200 * 1024

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
        return "human action required: stop requested"
    if (run_dir / "errors.md").exists():
        return "human action required: errors"
    state = optional_text(run_dir / "auto-loop-state.md")
    draft = optional_text(run_dir / "review-draft.md")
    combined = f"{state}\n{draft}".lower()
    if "human action required" in combined:
        return "human action required"
    if "decision: pending" in combined or "\npending\n" in combined:
        return "human action required: pending decision"
    return "available"


def page(title: str, body: str) -> bytes:
    nav = "".join(
        [
            route_link("/", "Dashboard"),
            route_link("/loops", "Loops"),
            route_link("/auto-loop", "Auto Loop"),
            route_link("/runs", "Runs"),
            route_link("/logics", "Logics"),
            route_link("/reviews", "Reviews"),
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
        self.send_error(405, "This read-only cockpit does not support POST actions.")

    def do_GET(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)
        query = parse_qs(parsed.query)
        routes = {
            "/": self.dashboard,
            "/loops": self.loops,
            "/loop": lambda: self.loop_detail(query),
            "/auto-loop": self.auto_loop,
            "/auto-loop-run": lambda: self.auto_loop_run(query),
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
        if latest_auto and "human action required" in auto_loop_status(latest_auto):
            warnings.append(f"Human action required in latest auto-loop run: {latest_auto.name}")
        latest_auto_html = "<p>No auto-loop runs found.</p>"
        if latest_auto:
            latest_rel = rel(repo, latest_auto)
            latest_auto_html = (
                f'<p><strong>Latest auto-loop:</strong> '
                f'<a href="/auto-loop-run?path={quote(latest_rel)}">{esc(latest_auto.name)}</a></p>'
                f'<p><strong>Status:</strong> {esc(auto_loop_status(latest_auto))}</p>'
                f'<p><strong>Latest event:</strong> {esc(latest_event(latest_auto))}</p>'
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
  <h2>Main sections</h2>
  <ul>
    <li>{route_link('/loops', 'Loop states')}</li>
    <li>{route_link('/auto-loop', 'Auto-loop runs')}</li>
    <li>{route_link('/runs', 'task-runs reports')}</li>
    <li>{route_link('/logics', 'Logics files')}</li>
    <li>{route_link('/reviews', 'Reviews')}</li>
    <li>{route_link('/debug', 'Debug')}</li>
  </ul>
</section>
"""
        return page("Dashboard", body)

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
            rows.append(
                "<tr>"
                f'<td><a href="/auto-loop-run?path={quote(path_rel)}">{esc(path.name)}</a></td>'
                f"<td>{esc(auto_loop_status(path))}</td>"
                f"<td>{esc(latest_event(path))}</td>"
                f"<td>{'yes' if (path / 'instructions.md').exists() else 'no'}</td>"
                f"<td>{'yes' if (path / 'stop-request.md').exists() else 'no'}</td>"
                f"<td>{'yes' if (path / 'errors.md').exists() else 'no'}</td>"
                "</tr>"
            )
        table = "".join(rows) or '<tr><td colspan="6">No auto-loop runs found.</td></tr>'
        body = f"""
<section><h2>Auto-loop runs</h2>
<table><thead><tr><th>Run</th><th>Status</th><th>Latest event</th><th>Instructions</th><th>Stop</th><th>Errors</th></tr></thead><tbody>{table}</tbody></table>
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
        action = '<div class="warn">Human action required.</div>' if "human action required" in status else '<div class="ok">No immediate human action detected.</div>'
        status_cmd = f"bash scripts/orchestia_loop.sh auto-loop-status {path_rel}"
        instruct_cmd = f'bash scripts/orchestia_loop.sh auto-loop-instruct {path_rel} "Add human instruction here."'
        stop_cmd = f'bash scripts/orchestia_loop.sh auto-loop-stop {path_rel} "Stop reason here."'

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
<p><strong>Latest event:</strong> {esc(latest_event(path))}</p>
<p>{route_link('/auto-loop', 'Back to auto-loop runs')}</p>
</section>
<section><h2>Copyable CLI commands</h2>
<pre>{esc(status_cmd)}
{esc(instruct_cmd)}
{esc(stop_cmd)}</pre>
<p class="muted">The cockpit does not execute these commands or modify Loop state.</p>
</section>
{section('Auto-loop state', 'auto-loop-state.md')}
{section('Events tail', 'events.log')}
{section('Errors', 'errors.md')}
{section('Instructions', 'instructions.md')}
{section('Stop request', 'stop-request.md')}
{section('Command preview', 'command-preview.md')}
{section('Review draft', 'review-draft.md')}
"""
        return page("Auto-loop run", body)

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
