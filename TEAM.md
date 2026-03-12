# TEAM.md — agent-track Team Charter
<!-- AgentSquad v1.0.0 | Generated: 2026-03-12 -->

## Mission
Build `agent-track`: a globally-installed Python CLI tool providing persistent memory
and task dispatch for Claude Code agents operating inside the AgentSquad framework.

## Team Composition

| Role | Runtime | Model | Responsibility |
|------|---------|-------|----------------|
| **Tech Lead** | Claude Code | claude-sonnet-4-6 | Architecture, delegation, review, commits |
| **Backend Engineer** | Gemini CLI | gemini-2.5-flash | DB, CRUD, business logic, get-next algorithm |
| **Frontend Engineer** | Gemini CLI | gemini-2.5-flash | Typer CLI, Rich UI, --agent flags, JSON output |
| **QA Engineer** | Gemini CLI | gemini-2.5-flash-lite | pytest suite, coverage, CLI integration tests |
| **DevOps Engineer** | Gemini CLI | gemini-2.5-flash-lite | pyproject.toml, uv, packaging, CI/CD |
| **Business Consultant** | Gemini CLI | gemini (web-search) | Schema design, architecture research |

## Coordination Protocol

### Task Dispatch
```
make backend  TASK="<atomic, self-contained instruction>"
make frontend TASK="<atomic, self-contained instruction>"
make qa       TASK="<atomic, self-contained instruction>"
make devops   TASK="<atomic, self-contained instruction>"
make consult  TASK="<atomic, self-contained instruction>"
```

### Escalation Rules
- Agent flags `[ESCALATE TO CLAUDE]` → Tech Lead reviews immediately
- Conflicting outputs → Tech Lead arbitrates, documents decision in `api-contracts/`
- Blocked agent → Tech Lead rewrites task with more context or breaks it smaller

### Handoff Protocol
1. Agent completes task → output in `agent-output/<timestamp>-<role>.md`
2. Tech Lead reviews output for correctness and integration fit
3. Tech Lead writes 1-sentence handoff summary (stored in DB by `agent-track` itself)
4. Summary surfaced to next dependent agent via `get-next --agent`

## Communication Standards
- All inter-agent context via `api-contracts/` files
- No verbal coordination — everything documented in files
- Task descriptions are self-contained (assume zero shared context)
- Output format: code files only, no prose explanations (agents use strip-filler)

## Definition of Done
A feature is DONE when:
- [ ] Implementation code committed
- [ ] Tests written and passing (`uv run pytest`)
- [ ] `--agent` / `--json` flag works on all new commands
- [ ] Handoff summary recorded
- [ ] Conventional commit created

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-03-12 | Global DB at `~/.agent-track.db` | Persists across project directories; single source of truth |
| 2026-03-12 | SQLite WAL mode | Concurrent reads without locking; safe for CLI use |
| 2026-03-12 | `--agent` flag on all commands | Machine-readable output for AI agent consumers |
| 2026-03-12 | uv as package manager | Fast, modern, deterministic Python packaging |
