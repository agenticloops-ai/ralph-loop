# Test Coverage Prompt

You are improving test coverage for this project.

@progress.txt

1. Read progress.txt and recent git log to understand current state.
2. Run the existing test suite and note coverage gaps.
3. Identify the most critical untested code path.
4. Write thorough tests for that code path, including edge cases.
5. If the code involves heuristics, thresholds, or detection logic, include eval-style tests using realistic data (not just synthetic inputs).
6. Run all tests. Ensure they pass.
7. Prepend to `progress.txt`. Use header format `## Session — YYYY-MM-DD HH:MM — Test: <module/path>` (get current date/time from the system).
8. Commit your changes.

ONLY COVER ONE MODULE OR CODE PATH PER SESSION.

If test coverage is satisfactory across all modules, output <promise>COMPLETE</promise>.
