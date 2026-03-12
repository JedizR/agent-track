# API Contract: Database Schema v1
> Approved: 2026-03-12 | Tech Lead review gate passed
> Informs: Backend Engineer (database.py, repository.py), QA Engineer (fixtures)

---

## Schema DDL (exact — do not deviate)

```sql
-- ─────────────────────────────────────────────
-- agent_registry: Agent-native discovery table
-- AI agents consuming the CLI query this table
-- to discover valid assigned_agent values, their
-- dispatch commands, and current models.
-- ─────────────────────────────────────────────
CREATE TABLE agent_registry (
    name         TEXT PRIMARY KEY,                -- canonical identifier used in tasks.assigned_agent
    make_command TEXT NOT NULL,                   -- exact make target: 'make backend', 'make frontend', etc.
    model        TEXT NOT NULL,                   -- current gemini model ID for this agent
    description  TEXT NOT NULL,                   -- one-line human/AI-readable role summary
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed data — inserted during schema init, never by user code
INSERT INTO agent_registry (name, make_command, model, description) VALUES
    ('backend',  'make backend',  'gemini-2.5-flash-lite', 'SQLite schema, CRUD operations, business logic'),
    ('frontend', 'make frontend', 'gemini-2.5-flash-lite', 'Typer CLI commands, Rich UI, --agent/--json flags'),
    ('qa',       'make qa',       'gemini-2.5-flash-lite', 'pytest suite, fixtures, CLI integration tests'),
    ('devops',   'make devops',   'gemini-2.5-flash-lite', 'pyproject.toml, uv packaging, GitHub Actions'),
    ('consult',  'make consult',  'gemini-3-flash-preview','Architecture research, schema design decisions');

-- ─────────────────────────────────────────────
-- projects
-- ─────────────────────────────────────────────
CREATE TABLE projects (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL UNIQUE,
    description TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- tasks
-- ─────────────────────────────────────────────
CREATE TABLE tasks (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id     INTEGER NOT NULL,
    title          TEXT    NOT NULL,
    description    TEXT,
    status         TEXT    NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending', 'in_progress', 'done', 'blocked')),
    priority       INTEGER NOT NULL DEFAULT 0,     -- higher = more urgent; no upper bound
    assigned_agent TEXT
                     CHECK (assigned_agent IS NULL OR
                            assigned_agent IN (
                                SELECT name FROM agent_registry
                            )),
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- updated_at trigger: DB-layer guarantee — fires on every UPDATE regardless of code path.
-- Do NOT update updated_at in Python; the trigger owns this column.
CREATE TRIGGER tasks_updated_at
AFTER UPDATE ON tasks
FOR EACH ROW
WHEN OLD.updated_at = NEW.updated_at     -- only fire if Python didn't set it explicitly
BEGIN
    UPDATE tasks SET updated_at = CURRENT_TIMESTAMP WHERE id = OLD.id;
END;

-- ─────────────────────────────────────────────
-- dependencies
-- ─────────────────────────────────────────────
CREATE TABLE dependencies (
    task_id            INTEGER NOT NULL,
    depends_on_task_id INTEGER NOT NULL,
    PRIMARY KEY (task_id, depends_on_task_id),
    CHECK (task_id != depends_on_task_id),         -- no self-dependency
    FOREIGN KEY (task_id)            REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (depends_on_task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- handoff_summaries
-- ─────────────────────────────────────────────
CREATE TABLE handoff_summaries (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id    INTEGER NOT NULL UNIQUE,            -- one summary per task, written on completion
    summary    TEXT    NOT NULL,                   -- 1-sentence technical summary for downstream agents
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- Indexes
-- ─────────────────────────────────────────────
-- Covers get-next query: WHERE status = 'pending' ORDER BY priority DESC, created_at ASC
CREATE INDEX idx_tasks_scheduling   ON tasks(status, priority DESC, created_at ASC);
-- Covers dependency resolution subquery: WHERE task_id = ?
CREATE INDEX idx_deps_task_id       ON dependencies(task_id);
-- Covers dependent lookup: WHERE depends_on_task_id = ? (cascade checks)
CREATE INDEX idx_deps_depends_on    ON dependencies(depends_on_task_id);
```

---

## Table Relationships

```
agent_registry (reference — seeded at init, read-only at runtime)
       ↑
       │ CHECK (assigned_agent IN (SELECT name ...))
       │
  projects (1) ──────────────────── (N) tasks
                                         │ (1)
                          ┌──────────────┤
                          │              │ (1)
                    dependencies    handoff_summaries
                 (task_id, depends_on_task_id)
                 CHECK: task_id != depends_on_task_id
```

---

## get-next Query (canonical — implement exactly)

```sql
SELECT t.*, ar.make_command, ar.model,
       hs.summary AS handoff_context
FROM tasks t
LEFT JOIN agent_registry  ar ON t.assigned_agent = ar.name
LEFT JOIN handoff_summaries hs ON t.id = hs.task_id
WHERE t.status = 'pending'
  AND NOT EXISTS (
      SELECT 1 FROM dependencies d
      JOIN tasks parent ON d.depends_on_task_id = parent.id
      WHERE d.task_id = t.id
        AND parent.status != 'done'
  )
ORDER BY t.priority DESC, t.created_at ASC
LIMIT 1;
```

**Output when `--agent` flag is passed:**
```json
{
  "command": "make backend",
  "task": "Build SQLite connection module with WAL mode enabled",
  "depends_on": [],
  "handoff_context": "Implemented schema migrations using sqlite3 executescript()."
}
```

---

## Business Rules

- `agent_registry` is seeded once on DB init and never modified by user code
- `assigned_agent` CHECK uses a subquery against `agent_registry` — adding a new agent only requires inserting into `agent_registry`, no DDL change
- `updated_at` is owned by the trigger — Python code must NOT set it manually
- `handoff_summaries` is written exactly once per task, on status transition to `done`
- `priority` is an unbounded integer; higher = more urgent; `get-next` uses `DESC`
- Circular dependency detection is NOT enforced at DB level — handled in Python `engine.py`

---

## Package Structure (final)

```
src/agent_track/
├── __init__.py          # version = "0.1.0"
├── __main__.py          # python -m agent_track entry point
├── cli.py               # Root Typer app; --agent/--json as global callbacks
├── commands/
│   ├── __init__.py
│   ├── projects.py      # project add / list / delete
│   ├── tasks.py         # task add / update / complete / list
│   └── scheduler.py     # get-next: runs canonical query, formats AgentSquad output
├── core/
│   ├── __init__.py
│   ├── database.py      # get_connection(), init_schema(), WAL mode, FOREIGN_KEYS=ON
│   ├── repository.py    # All parameterised SQL — no raw queries outside this file
│   └── engine.py        # get_next_task(), detect_cycles() business logic
├── models/
│   ├── __init__.py
│   ├── domain.py        # dataclasses: Task, Project, Dependency, HandoffSummary, AgentInfo
│   └── schemas.py       # Pydantic v2 models for --agent/--json serialisation
└── utils/
    ├── __init__.py
    ├── formatting.py    # Rich tables, Kanban board, progress bars
    └── paths.py         # DB_PATH = Path.home() / ".agent-track.db"
```

---

## Out of Scope (v1)

- Task archival / soft delete (deferred to v1.1)
- Multi-user / team support (global DB is single-user by design)
- Task tags or labels
- Recurring tasks
