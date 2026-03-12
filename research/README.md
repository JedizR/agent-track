# Research

This directory is where the Business Consultant agent writes research findings.
All architecture decisions, schema proposals, and competitive analysis land here.

## Usage

Dispatch the consultant agent and it will write output to `agent-output/`, which
the Tech Lead then reviews and promotes to this directory:

```bash
make consult TASK="Design the optimal SQLite schema for agent-track"
# Review agent-output/<timestamp>-consult.md
# Promote to research/schema-design.md if approved
```

## Files in This Directory

| File | Topic | Date |
|------|-------|------|
| _(populated after first consult dispatch)_ | — | — |
