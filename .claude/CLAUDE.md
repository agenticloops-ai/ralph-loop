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
- **Timestamp:** include the current date/time in each session header using format `## Session — YYYY-MM-DD HH:MM — <task ID>: <description>`
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
- `.ralph/templates/` — Example files for PRD and progress
- `.ralph/*.sh` — Ralph loop scripts (init, once, loop, sandbox)
- `.claude/CLAUDE.md` — Project instructions for Claude Code
- `src/` — Application source code
- `tests/` — Test files
