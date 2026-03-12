# API Contracts

This directory contains interface contracts written by the Tech Lead **before** dispatching
implementation agents. Every agent task that crosses domain boundaries must have a contract here first.

## Purpose

Contracts eliminate ambiguity. When the Frontend agent builds a CLI command that calls a Backend
function, both agents must agree on the function signature, return types, and error behavior
before either writes a line of code.

## Contract Format

Each contract file covers a single interface boundary:

```markdown
# <feature-name>.md

## Function / Module
`from agent_track.<module> import <name>`

## Signature
```python
def function_name(param: Type) -> ReturnType: ...
```

## Inputs
| Parameter | Type | Description |

## Returns
| Field | Type | Description |

## Errors
| Exception | When |

## Example
```python
# usage example
```
```

## Files in This Directory

| File | Covers |
|------|--------|
| `auth.example.md` | Example contract structure |
| `db-connection.md` | SQLite connection module interface |
| `crud-tasks.md` | Tasks CRUD interface |
| `get-next.md` | get-next algorithm interface |
