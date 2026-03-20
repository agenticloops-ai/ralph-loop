# Refactor Prompt

You are refactoring this codebase for clarity, maintainability, and consistency.

@prd.json @progress.txt

1. Read progress.txt and recent git log (`git log --oneline -10`) to understand current state.
2. Scan the codebase for the most impactful refactoring opportunity. Prioritize:
   - Duplicated logic that should be extracted into shared functions/modules
   - Overly complex functions (high cyclomatic complexity, deep nesting)
   - Inconsistent naming or patterns across similar modules
   - Dead code or unused imports
   - Poor separation of concerns (e.g., business logic mixed with I/O)
3. **Safety gate:** Before refactoring, ensure full test coverage exists for the code you plan to change. If tests are missing, write them FIRST.
4. Perform the refactoring. Preserve all existing behavior — this is a pure restructuring, not a feature change.
5. Run all tests and type checks. Every test must pass. If a test fails, your refactoring introduced a regression — fix it.
6. Prepend to `progress.txt`. Use header format `## Session — YYYY-MM-DD HH:MM — Refactor: <module/path>` (get current date/time from the system).
7. Commit with a message explaining WHY the refactoring improves the code, not just WHAT changed.

ONLY REFACTOR ONE MODULE OR CONCERN PER SESSION.

If the codebase is clean and no meaningful refactoring opportunities remain, output <promise>COMPLETE</promise>.
