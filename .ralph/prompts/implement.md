# Implementation Prompt

You are working on a software project. Follow the instructions in CLAUDE.md strictly.

## Your Task

@.ralph/prd.json @.ralph/progress.txt

1. Read the PRD (.ralph/prd.json) and progress file carefully.
2. Identify the highest-priority incomplete task (first task with `"done": false`).
3. **Conflict check:** Review recent git history (`git log --oneline -10`). If the task would undo, redo, or conflict with recently completed work, note this in .ralph/progress.txt and skip to the next task.
4. Search the codebase to understand existing code before making changes.
5. Implement the task fully — no placeholders, no stubs.
6. Write or update tests to cover the new functionality.
7. Run all tests and type checks. Fix any failures.
8. Prepend to `.ralph/progress.txt`. Use header format `## Session — YYYY-MM-DD HH:MM — <task ID>: <description>` (get current date/time from the system).
9. Mark the task as complete in `.ralph/prd.json` (set `"done": true`). Preserve valid JSON.
10. Commit each logical change separately. If the task touches multiple independent concerns, make multiple commits. Each commit message should be descriptive.

ONLY WORK ON A SINGLE TASK.

If all tasks in the PRD are complete, output <promise>COMPLETE</promise>.
