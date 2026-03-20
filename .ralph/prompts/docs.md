# Documentation Prompt

You are improving inline documentation and developer guides for this project.

@prd.json @progress.txt

1. Read progress.txt and recent git log (`git log --oneline -10`) to understand current state.
2. Identify the most critical undocumented or poorly documented area. Prioritize:
   - Public API functions/endpoints with no docstrings or JSDoc
   - Complex algorithms or business logic with no explanatory comments
   - Configuration files or environment variables with no usage guide
   - Missing or outdated inline comments on non-obvious code paths
3. **Accuracy gate:** Read and understand the code thoroughly before writing documentation. Never document behavior you haven't verified by reading the implementation.
4. Write clear, concise documentation:
   - Add docstrings/JSDoc to public functions with parameter descriptions and return values
   - Add brief inline comments only where logic is non-obvious
   - Do NOT over-document — skip self-evident code
5. Run all tests to ensure documentation changes (e.g., docstring syntax) don't break anything.
6. Prepend to `progress.txt`. Use header format `## Session — YYYY-MM-DD HH:MM — Docs: <module/path>` (get current date/time from the system).
7. Commit your changes.

ONLY DOCUMENT ONE MODULE OR AREA PER SESSION.

If documentation coverage is satisfactory across all modules, output <promise>COMPLETE</promise>.
