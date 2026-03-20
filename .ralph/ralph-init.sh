#!/usr/bin/env bash
# Ralph Setup Wizard — Interactive project initialization
# Generates .ralph/prd.json, .claude/CLAUDE.md, and .ralph/progress.txt
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# --- Trap: clean exit on Ctrl+C ---
trap 'echo ""; echo "Aborted. No files were modified."; exit 1' INT

# --- Colors ---
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

# ============================================================================
# Utility functions
# ============================================================================

prompt_text() {
  local label="$1"
  local required="${2:-true}"
  local value=""

  while true; do
    printf "${CYAN}${label}:${RESET} " >&2
    read -r value
    if [ -n "$value" ]; then
      echo "$value"
      return
    fi
    if [ "$required" = "false" ]; then
      echo ""
      return
    fi
    printf "${RED}  This field is required.${RESET}\n" >&2
  done
}

confirm() {
  local label="$1"
  local default="${2:-n}"
  local prompt_hint="[y/N]"
  if [ "$default" = "y" ]; then
    prompt_hint="[Y/n]"
  fi

  printf "${YELLOW}${label} ${prompt_hint}:${RESET} "
  read -r answer
  answer="${answer:-$default}"
  case "$answer" in
    [Yy]*) return 0 ;;
    *) return 1 ;;
  esac
}

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  echo "$s"
}

# ============================================================================
# Idempotency guard
# ============================================================================

echo ""
printf "${BOLD}=== Ralph Setup Wizard ===${RESET}\n"
echo ""

OVERWRITE_FILES=()

has_real_content() {
  local file="$1"
  local placeholder="$2"
  if [ -f "$file" ] && ! grep -q "$placeholder" "$file" 2>/dev/null; then
    return 0
  fi
  return 1
}

if has_real_content ".ralph/prd.json" '"project": "TBD"'; then
  OVERWRITE_FILES+=(".ralph/prd.json")
fi
if has_real_content ".claude/CLAUDE.md" "TBD — see .ralph/prd.json"; then
  OVERWRITE_FILES+=(".claude/CLAUDE.md")
fi
if [ ${#OVERWRITE_FILES[@]} -gt 0 ]; then
  printf "${YELLOW}The following files appear to have been configured already:${RESET}\n"
  for f in "${OVERWRITE_FILES[@]}"; do
    printf "  - %s\n" "$f"
  done
  echo ""
  if ! confirm "Overwrite these files?"; then
    echo "Aborted. No files were modified."
    exit 0
  fi
  echo ""
fi

if [ -f ".ralph/progress.txt" ] && [ -s ".ralph/progress.txt" ]; then
  printf "${RED}WARNING: .ralph/progress.txt has content. Re-running the wizard will reset it.${RESET}\n"
  if ! confirm "Continue and reset progress.txt?"; then
    echo "Aborted. No files were modified."
    exit 0
  fi
  echo ""
fi

# ============================================================================
# Interactive prompts
# ============================================================================

printf "${BOLD}Project Details${RESET}\n"
PROJECT_NAME=$(prompt_text "Project name")
PROJECT_DESC=$(prompt_text "Description (one line)")

# ============================================================================
# Confirmation summary
# ============================================================================

echo ""
printf "${BOLD}=== Configuration Summary ===${RESET}\n"
echo ""
printf "  Project:     ${BOLD}%s${RESET}\n" "$PROJECT_NAME"
printf "  Description: %s\n" "$PROJECT_DESC"
echo ""
printf "${DIM}Files to generate:${RESET}\n"
printf "  - .ralph/prd.json\n"
printf "  - .claude/CLAUDE.md\n"
printf "  - .ralph/progress.txt (reset)\n"
echo ""

if ! confirm "Generate files with these settings?" "y"; then
  echo "Aborted. No files were modified."
  exit 0
fi

echo ""

# ============================================================================
# Generate prd.json
# ============================================================================

ESCAPED_NAME=$(json_escape "$PROJECT_NAME")
ESCAPED_DESC=$(json_escape "$PROJECT_DESC")

cat > "$PROJECT_DIR/.ralph/prd.json" << PRDEOF
{
  "project": "${ESCAPED_NAME}",
  "description": "${ESCAPED_DESC}",
  "tech_stack": {
    "language": "",
    "framework": "",
    "database": "",
    "testing": "",
    "package_manager": ""
  },
  "phases": [
    {
      "name": "Phase 1: Foundation",
      "tasks": [
        { "id": "1.1", "description": "Define tech stack and update prd.json and CLAUDE.md", "done": false },
        { "id": "1.2", "description": "Initialize project and install core dependencies", "done": false },
        { "id": "1.3", "description": "Create basic project structure and verify build/run", "done": false },
        { "id": "1.4", "description": "Configure test framework and write a smoke test", "done": false }
      ]
    },
    {
      "name": "Phase 2: Core Features",
      "tasks": [
        { "id": "2.1", "description": "TODO: Define core feature tasks", "done": false }
      ]
    },
    {
      "name": "Phase 3: Polish",
      "tasks": [
        { "id": "3.1", "description": "TODO: Define polish tasks", "done": false }
      ]
    }
  ],
  "bugs": [],
  "completion_criteria": [
    "All tasks done",
    "All tests passing",
    "No open bugs"
  ]
}
PRDEOF

printf "${GREEN}  Created .ralph/prd.json${RESET}\n"

# ============================================================================
# Generate .claude/CLAUDE.md
# ============================================================================

cat > "$PROJECT_DIR/.claude/CLAUDE.md" << 'CLAUDEEOF'
# Project Instructions

## Overview

This project uses the Ralph Wiggum Loop pattern for agentic development with Claude Code.
Product requirements are defined in `.ralph/prd.json`. Progress is tracked in `.ralph/progress.txt`.

## Session Startup Protocol

Every session MUST follow this sequence:

1. Run `pwd` to confirm working directory
2. Review `git log --oneline -10` for recent changes
3. Read `.ralph/progress.txt` for completed work and known issues
4. Read `.ralph/prd.json` and identify the highest-priority incomplete task (first task with `"done": false`)
5. Only then begin implementation work

## Development Rules

### One Task Per Session
- Work on exactly ONE task per session
- Complete it fully (implement, test, verify) before stopping
- Never start a second task in the same session

### Code Quality
- Run all tests and type checks before committing
- Never commit code that breaks existing tests
- It is unacceptable to remove or edit existing tests to make them pass
- Write tests for new functionality
- Follow existing code patterns and conventions in the codebase

### Progress Tracking
- **Prepend** new entries to `.ralph/progress.txt` (newest first) so the most relevant context is always at the top
- **10-line max per session:** task ID, 1-3 bullets of what was done, key decisions, blockers — no exhaustive file lists
- **200-line cap:** if `.ralph/progress.txt` exceeds 200 lines, keep the first 50 lines (recent) + last 10 lines (origin), remove the middle
- Update `.ralph/prd.json` to mark the completed task (set `"done": true`). Preserve valid JSON.
- Commit with a descriptive message

### Safety
- Never overwrite or delete `.ralph/progress.txt`
- Never modify `.ralph/prd.json` structure — only update task `"done"` status
- When editing `.ralph/prd.json`, preserve valid JSON — do not corrupt the file
- Always search codebase before implementing (don't assume something doesn't exist)
- DO NOT implement placeholder or stub implementations — write full, working code
- If a task is too large for one session, add subtask entries to the phase in `.ralph/prd.json`

### Git Discipline
- Make atomic commits (one logical change per commit)
- Never bundle unrelated changes in a single commit — even if part of the same task
- Write descriptive commit messages explaining WHY, not just WHAT
- Tag stable milestones when all tests pass

## Tech Stack

<!-- Define your tech stack here when requirements are set -->
TBD — see .ralph/prd.json

## File Map

- `.ralph/prd.json` — Product requirements document (source of truth for tasks and bugs, JSON format)
- `.ralph/progress.txt` — Session-by-session progress log
- `.ralph/prompts/` — Prompt templates for different loop modes
- `.ralph/*.sh` — Ralph loop scripts (init, once, loop, sandbox)
- `.claude/CLAUDE.md` — Project instructions for Claude Code
- `src/` — Application source code
- `tests/` — Test files
CLAUDEEOF

printf "${GREEN}  Created .claude/CLAUDE.md${RESET}\n"

# ============================================================================
# Reset progress.txt
# ============================================================================

: > "$PROJECT_DIR/.ralph/progress.txt"
printf "${GREEN}  Reset .ralph/progress.txt${RESET}\n"

# ============================================================================
# Remove old prd.md if present (migrated to prd.json)
# ============================================================================

if [ -f "$PROJECT_DIR/prd.md" ]; then
  rm "$PROJECT_DIR/prd.md"
  printf "${GREEN}  Removed old prd.md (migrated to prd.json)${RESET}\n"
fi

if [ -f "$PROJECT_DIR/fix_plan.md" ]; then
  rm "$PROJECT_DIR/fix_plan.md"
  printf "${GREEN}  Removed old fix_plan.md (bugs tracked in prd.json)${RESET}\n"
fi

if [ -f "$PROJECT_DIR/init.sh" ]; then
  rm "$PROJECT_DIR/init.sh"
  printf "${GREEN}  Removed old init.sh (no longer needed)${RESET}\n"
fi

# ============================================================================
# Patch README.md
# ============================================================================

if [ -f "$PROJECT_DIR/README.md" ]; then
  if ! grep -q "ralph-init.sh" "$PROJECT_DIR/README.md" 2>/dev/null; then
    # Insert Step 0 before "### 1. Define Your Product"
    TMPFILE=$(mktemp)
    while IFS= read -r line; do
      if [[ "$line" == "### 1. Define Your Product" ]]; then
        cat << 'WIZARDEOF'
### 0. Run the Setup Wizard (Recommended)

```bash
.ralph/ralph-init.sh
```

Interactively generates `.ralph/prd.json` and `.claude/CLAUDE.md` for your project. Skip this and configure manually if you prefer.

WIZARDEOF
      fi
      printf '%s\n' "$line"
    done < "$PROJECT_DIR/README.md" > "$TMPFILE"
    mv "$TMPFILE" "$PROJECT_DIR/README.md"
    printf "${GREEN}  Patched README.md with Step 0${RESET}\n"
  else
    printf "${DIM}  README.md already has wizard section${RESET}\n"
  fi
fi

# ============================================================================
# Summary
# ============================================================================

echo ""
printf "${BOLD}=== Setup Complete ===${RESET}\n"
echo ""
printf "Generated files:\n"
printf "  .ralph/prd.json      — PRD with Phase 1 bootstrap tasks\n"
printf "  .claude/CLAUDE.md    — Project instructions\n"
printf "  .ralph/progress.txt  — Reset (empty)\n"
echo ""
printf "${BOLD}Next steps:${RESET}\n"
printf "  1. Edit .ralph/prd.json — define your tech stack and Phase 2/3 tasks\n"
printf "  2. Run ${CYAN}.ralph/ralph-once.sh${RESET} to start the first Ralph iteration\n"
echo ""
