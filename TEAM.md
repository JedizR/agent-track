# agent-track — Team Charter
> AgentSquad v1.0.0 · 2026-03-12

This document describes how the team operates. It is for human contributors
and AI agents alike.

---

## The Team

### Tech Founder (You + Claude Code)
**Owns:** Everything. The final say on all decisions.

The human founder drives strategy, product direction, and architecture.
Claude Code is the technical co-founder — architecting systems, reviewing all
agent output, and making the calls that require judgment.

**You decide:** What to build, how the system is designed, what gets shipped.

### Backend Engineer (Gemini Flash)
**Owns:** `src/agent_track/db/`, `src/agent_track/crud/`, `src/agent_track/models/`, `src/agent_track/core/`

Implements SQLite schema, all CRUD operations, dependency resolution logic,
and the `get-next` unblocked-task algorithm. Always works from an
`api-contracts/*.md` file authored by Claude before starting.

### Frontend Engineer (Gemini Flash)
**Owns:** `src/agent_track/cli/`, `src/agent_track/ui/`

Builds all Typer CLI commands, Rich Kanban boards, status tables, and
progress indicators. Every command must support `--agent` / `--json` flags
that return pure, parseable output — zero prose. `get-next` must return
a ready-to-paste `make <agent> TASK="..."` string when `--agent` is passed.

### QA Engineer (Gemini Flash)
**Owns:** `tests/`

Writes pytest unit tests (CRUD, dependency resolution, get-next logic) and
integration tests via `typer.testing.CliRunner`. Coverage target: 80%+.
Uses fixtures; no hardcoded DB state.

### DevOps Engineer (Gemini Flash)
**Owns:** `pyproject.toml`, `.github/workflows/`, `Makefile` (build targets)

Configures uv packaging, entry points (`agent-track` CLI command), and
CI pipeline. Annotates every new env variable with `[REQUIRES MANUAL STEP]`.

### Business Consultant (Gemini Flash + Google Search)
**Owns:** `research/`

Researches schema patterns, CLI UX benchmarks, and architecture decisions
using real-time Google Search. Used before major design decisions — not
per-feature.

---

## Working Norms

### Communication
- Claude writes task prompts for each agent — the clearer the prompt, the better the output
- All agent output goes to `agent-output/` (gitignored) — review before integrating
- Escalations (`[ESCALATE TO CLAUDE]`) are resolved by the human + Claude before continuing

### Code Ownership
- No agent modifies another agent's domain without Claude coordinating the handoff
- `api-contracts/` is Claude-only territory — agents only READ these, never write them
- `src/agent_track/core/` integration points are Claude's responsibility to wire together

### Quality Gates
- No code integrated without Claude review
- `uv run pytest` passes before every commit
- Every Typer command supports `--agent` / `--json` before it is considered done
- `uv run mypy src/` passes with no errors

### Security
- All API keys stored only in `~/.agent-team/.env.team` — never in code
- Global DB at `~/.agent-track.db` — never checked in, never hardcoded

---

## Getting Started (New Machine)

```bash
# 1. Install AgentSquad
bash <(curl -fsSL https://raw.githubusercontent.com/JedizR/agentsquad/main/install.sh)

# 2. Add your API key
nano ~/.agent-team/.env.team   # set GEMINI_API_KEY

# 3. Load credentials
source ~/.agent-team/.env.team

# 4. Verify team config
make team-health

# 5. Install agent-track
uv tool install .

# 6. Run
agent-track --help
```
