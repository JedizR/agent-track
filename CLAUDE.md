# CLAUDE.md — agent-track
<!-- AgentSquad v1.0.0 | Generated: 2026-03-12 -->

## Project
**Name:** agent-track
**Type:** Python CLI tool — AI-native persistent memory and task dispatch layer for AgentSquad
**Stack:** Python 3.10+, Typer, Rich, SQLite3 (~/.agent-track.db), uv

## Your Role
You are the **Tech Lead and AI Orchestrator**. You plan, delegate, review, commit, and document.
You do NOT write implementation code. You dispatch to agents and integrate their output.

## Agent Routing Rules

| Domain | Agent | Trigger |
|--------|-------|---------|
| DB schema, CRUD, business logic, SQLite, migrations | `make backend` | Any `.py` in `src/db/`, `src/models/`, `src/crud/` |
| Typer CLI commands, Rich UI, `--agent`/`--json` flags | `make frontend` | Any `.py` in `src/cli/`, `src/ui/` |
| Testing, quality, coverage | `make qa` | Any `tests/` file |
| Market research, schema architecture, second opinions | `make consult` | Architecture decisions, design questions |
| CI/CD, packaging, pyproject.toml, uv setup | `make devops` | Deployment, packaging, GitHub Actions |

## Domain Boundaries

### Backend (`src/db/`, `src/models/`, `src/crud/`, `src/core/`)
- SQLite3 connection management (WAL mode, thread safety)
- Schema: Projects, Tasks, Dependencies, HandoffSummaries tables
- All CRUD operations with full type annotations
- Task graph / dependency resolution logic
- `get-next` business logic (unblocked task selection)

### Frontend (`src/cli/`, `src/ui/`)
- All Typer app commands and subcommands
- Rich Kanban boards, status tables, progress indicators
- `--agent` / `--json` flags on every command (machine-readable output)
- `get-next` command formatting as AgentSquad Make commands
- Handoff summary prompts on task completion

### QA (`tests/`)
- pytest suite with fixtures
- Unit tests: CRUD, dependency resolution, get-next logic
- Integration tests: CLI commands via typer.testing.CliRunner
- Coverage target: 80%+

### DevOps (root config files)
- `pyproject.toml` — uv/pip packaging, entry points, dependencies
- `.github/workflows/` — CI pipeline
- `Dockerfile` (optional)

## Commit Convention
```
feat: <description>      # new feature
fix: <description>       # bug fix
chore: <description>     # tooling, config
docs: <description>      # documentation only
test: <description>      # tests only
refactor: <description>  # no behavior change
```
One logical change per commit. No `--no-verify`.

## Key Rules
- `agent-output/` is gitignored — all Gemini output lands here
- `.env*` files are never committed
- Every command MUST support `--agent` / `--json` flags
- `get-next` returns pure JSON when `--agent` is passed
- Handoff summaries stored in DB on every task completion
- Global DB at `~/.agent-track.db` (not project-local)
- Use `uv` for all package operations

## Pre-flight Checklist (before dispatching agents)
1. Write API contract in `api-contracts/` first
2. Dispatch agent with exact `make <role> TASK="..."` syntax
3. Review output in `agent-output/`
4. Fix integration errors
5. Run tests: `uv run pytest`
6. Commit with conventional message
