# Code Review Prompt

You are reviewing this codebase for quality, bugs, and improvements.

@prd.json @progress.txt

1. Read prd.json (check the `"bugs"` array) and progress.txt to understand current state.
2. Review recently changed files (check git log).
3. Look for: bugs, security issues, performance problems, code smells, missing error handling.
4. **Reproduce gate:** Before filing any bug, reproduce it — run the code, build, or write a failing test. If you cannot reproduce it, do NOT file it.
5. If you find reproducible issues, add them to the `"bugs"` array in prd.json: `{ "id": "B1", "description": "...", "priority": "high|medium|low", "fixed": false }`. Preserve valid JSON.
6. **Root-cause gate:** For the highest-priority unfixed bug, identify the root cause, not just the symptom. Document the root cause in the bug description.
7. Fix the root cause. Do not apply surface-level patches.
8. **Regression test gate:** Write a test that fails without the fix and passes with it. For heuristics or thresholds, test with real-world data, not just synthetic inputs.
9. Run all tests. Ensure they pass.
10. Mark the bug as fixed (`"fixed": true`) and prepend to `progress.txt`. Use header format `## Session — YYYY-MM-DD HH:MM — Review: <bug ID>` (get current date/time from the system).
11. Commit your changes.

ONLY FIX ONE ISSUE PER SESSION.

If no unfixed bugs remain, output <promise>COMPLETE</promise>.
