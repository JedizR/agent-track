# Makefile — agent-track AgentSquad Dispatch
# AgentSquad v1.0.0 | Generated: 2026-03-12
#
# Usage:
#   make backend  TASK="implement the SQLite connection module"
#   make frontend TASK="build the task list command with Rich table"
#   make qa       TASK="write pytest tests for CRUD operations"
#   make devops   TASK="set up pyproject.toml with uv and entry points"
#   make consult  TASK="design optimal SQLite schema for agent-track"

SHELL := /bin/bash
OUTPUT_DIR := agent-output
TIMESTAMP := $(shell date +%Y%m%d-%H%M%S)

# Load credentials
-include ~/.agent-team/.env.team
export

# ─────────────────────────────────────────────
# Agent Dispatch Targets
# ─────────────────────────────────────────────

.PHONY: backend
backend: _check-task _ensure-output-dir
	@echo "→ Dispatching to Backend Engineer..."
	@source ~/.agent-team/.env.team && \
	  source ~/.agent-team/scripts/gemini-call.sh && \
	  call_gemini \
	    "$${GEMINI_KEY_BACKEND:-$$GEMINI_API_KEY}" \
	    "$$(cat ~/.agent-team/skills/backend-engineer/SKILL.md) \n\nPROJECT CONTEXT:\n$$(cat CLAUDE.md)\n\nTASK: $(TASK)" \
	    "$(OUTPUT_DIR)/$(TIMESTAMP)-backend.md" \
	    "gemini-2.5-flash"
	@echo "✓ Output: $(OUTPUT_DIR)/$(TIMESTAMP)-backend.md"

.PHONY: frontend
frontend: _check-task _ensure-output-dir
	@echo "→ Dispatching to Frontend Engineer..."
	@source ~/.agent-team/.env.team && \
	  source ~/.agent-team/scripts/gemini-call.sh && \
	  call_gemini \
	    "$${GEMINI_KEY_FRONTEND:-$$GEMINI_API_KEY}" \
	    "$$(cat ~/.agent-team/skills/frontend-engineer/SKILL.md) \n\nPROJECT CONTEXT:\n$$(cat CLAUDE.md)\n\nTASK: $(TASK)" \
	    "$(OUTPUT_DIR)/$(TIMESTAMP)-frontend.md" \
	    "gemini-2.5-flash"
	@echo "✓ Output: $(OUTPUT_DIR)/$(TIMESTAMP)-frontend.md"

.PHONY: qa
qa: _check-task _ensure-output-dir
	@echo "→ Dispatching to QA Engineer..."
	@source ~/.agent-team/.env.team && \
	  source ~/.agent-team/scripts/gemini-call.sh && \
	  call_gemini \
	    "$${GEMINI_KEY_QA:-$$GEMINI_API_KEY}" \
	    "$$(cat ~/.agent-team/skills/qa-engineer/SKILL.md) \n\nPROJECT CONTEXT:\n$$(cat CLAUDE.md)\n\nTASK: $(TASK)" \
	    "$(OUTPUT_DIR)/$(TIMESTAMP)-qa.md" \
	    "gemini-2.5-flash-lite"
	@echo "✓ Output: $(OUTPUT_DIR)/$(TIMESTAMP)-qa.md"

.PHONY: devops
devops: _check-task _ensure-output-dir
	@echo "→ Dispatching to DevOps Engineer..."
	@source ~/.agent-team/.env.team && \
	  source ~/.agent-team/scripts/gemini-call.sh && \
	  call_gemini \
	    "$${GEMINI_KEY_DEVOPS:-$$GEMINI_API_KEY}" \
	    "$$(cat ~/.agent-team/skills/devops-engineer/SKILL.md) \n\nPROJECT CONTEXT:\n$$(cat CLAUDE.md)\n\nTASK: $(TASK)" \
	    "$(OUTPUT_DIR)/$(TIMESTAMP)-devops.md" \
	    "gemini-2.5-flash-lite"
	@echo "✓ Output: $(OUTPUT_DIR)/$(TIMESTAMP)-devops.md"

.PHONY: consult
consult: _check-task _ensure-output-dir
	@echo "→ Dispatching to Business Consultant..."
	@source ~/.agent-team/.env.team && \
	  source ~/.agent-team/scripts/gemini-call.sh && \
	  call_gemini \
	    "$${GEMINI_KEY_CONSULTANT:-$$GEMINI_API_KEY}" \
	    "$$(cat ~/.agent-team/skills/business-consultant/SKILL.md) \n\nPROJECT CONTEXT:\n$$(cat CLAUDE.md)\n\nTASK: $(TASK)" \
	    "$(OUTPUT_DIR)/$(TIMESTAMP)-consult.md" \
	    "gemini-2.5-flash"
	@echo "✓ Output: $(OUTPUT_DIR)/$(TIMESTAMP)-consult.md"

# ─────────────────────────────────────────────
# Utility Targets
# ─────────────────────────────────────────────

.PHONY: team-health
team-health:
	@echo "→ Running agent health check..."
	@source ~/.agent-team/.env.team && ~/.agent-team/scripts/health-check.sh

.PHONY: clean-output
clean-output:
	@echo "→ Cleaning agent-output/..."
	@rm -f $(OUTPUT_DIR)/*.md
	@echo "✓ Cleaned"

.PHONY: dev
dev:
	@uv run agent-track --help

.PHONY: test
test:
	@uv run pytest tests/ -v

.PHONY: lint
lint:
	@uv run ruff check src/ tests/

.PHONY: typecheck
typecheck:
	@uv run mypy src/

.PHONY: help
help:
	@echo ""
	@echo "agent-track — AgentSquad Dispatch Commands"
	@echo "─────────────────────────────────────────────"
	@echo "  make backend  TASK='...'  → Backend Engineer (DB, CRUD, logic)"
	@echo "  make frontend TASK='...'  → Frontend Engineer (CLI, Rich UI)"
	@echo "  make qa       TASK='...'  → QA Engineer (tests, coverage)"
	@echo "  make devops   TASK='...'  → DevOps Engineer (packaging, CI/CD)"
	@echo "  make consult  TASK='...'  → Business Consultant (research, design)"
	@echo ""
	@echo "  make team-health          → Verify all agents are operational"
	@echo "  make clean-output         → Remove generated agent-output/ files"
	@echo "  make test                 → Run pytest suite"
	@echo "  make lint                 → Run ruff linter"
	@echo "  make typecheck            → Run mypy"
	@echo ""

# ─────────────────────────────────────────────
# Internal helpers
# ─────────────────────────────────────────────

.PHONY: _check-task
_check-task:
	@if [ -z "$(TASK)" ]; then \
	  echo "Error: TASK is required. Usage: make <agent> TASK='your instruction'"; \
	  exit 1; \
	fi

.PHONY: _ensure-output-dir
_ensure-output-dir:
	@mkdir -p $(OUTPUT_DIR)
