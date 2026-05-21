# REVIEW-0003: Gitignore Policy

## Metadata

- ID: REVIEW-0003
- Status: Accepted
- Task: [TASK-0004 Add Gitignore Policy](../tasks/TASK-0004-add-gitignore-policy.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)

## Checks

- `test -f task-runs/.gitkeep`
- `test -f .gitignore`
- `git check-ignore task-runs/example-run/output.log`
- `git check-ignore .env`
- `git check-ignore node_modules/example`
- `git check-ignore -v task-runs/.gitkeep || true`
- `git status --short --untracked-files=all`
- `git diff --stat`

## Result

The ignore policy keeps generated runtime outputs and common local artifacts out of Git by default while preserving the tracked placeholder for `task-runs/`.

## Accepted

- Generated `task-runs/*` content is ignored.
- `task-runs/.gitkeep` remains trackable.
- `.env` and `.env.*` files are ignored.
- `.env.example` remains allowed.
- Common local build, dependency, cache, coverage, and system artifacts are ignored.

## Risks

- A generated task-run directory that should become a reviewed artifact must be copied or renamed into an intentional tracked Logics document.
- Future tooling may need additional ignore entries, but broad source-file patterns should be avoided.

## Next Step

Use the helper scripts normally and commit only intentional project memory, documentation, scripts, and source files.
