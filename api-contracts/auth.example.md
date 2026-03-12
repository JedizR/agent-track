# Example API Contract — Reference Template

## Function / Module
`from agent_track.core.db import get_connection`

## Signature
```python
def get_connection() -> sqlite3.Connection: ...
```

## Inputs
_None — uses global config for DB path_

## Returns
| Field | Type | Description |
|-------|------|-------------|
| connection | `sqlite3.Connection` | Thread-safe WAL-mode connection to `~/.agent-track.db` |

## Errors
| Exception | When |
|-----------|------|
| `DatabaseError` | DB file unreadable or schema version mismatch |

## Contract Rules
- Caller must NOT close the connection (managed by connection pool)
- WAL mode is already set; do not issue `PRAGMA journal_mode` again
- `check_same_thread=False` is set; safe to use from Typer async context

## Example
```python
from agent_track.core.db import get_connection

conn = get_connection()
cursor = conn.cursor()
cursor.execute("SELECT * FROM tasks WHERE status = 'pending'")
```
