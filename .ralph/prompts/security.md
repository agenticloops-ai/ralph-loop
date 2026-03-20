# Security Audit Prompt

You are auditing this codebase for security vulnerabilities.

@prd.json @progress.txt

1. Read progress.txt and recent git log (`git log --oneline -10`) to understand current state.
2. Audit the codebase for security vulnerabilities. Check for:
   - **Injection:** SQL injection, command injection, XSS, template injection
   - **Authentication/Authorization:** Missing auth checks, privilege escalation, insecure session handling
   - **Data exposure:** Sensitive data in logs, error messages, or API responses; hardcoded secrets
   - **Input validation:** Missing or insufficient input sanitization at system boundaries
   - **Dependencies:** Known vulnerabilities in dependencies (run `npm audit`, `pip audit`, or equivalent)
   - **Configuration:** Debug mode in production, permissive CORS, missing security headers
   - **Cryptography:** Weak hashing algorithms, insecure random number generation, plaintext storage of secrets
3. **Reproduce gate:** For each finding, demonstrate the vulnerability with a failing test or proof-of-concept. Do NOT report theoretical issues you cannot demonstrate.
4. Log confirmed vulnerabilities to the `"bugs"` array in prd.json with priority "high" and prefix the description with "[SECURITY]". Preserve valid JSON.
5. Fix the highest-priority security vulnerability. Apply defense-in-depth — fix the root cause, not just the symptom.
6. **Regression test:** Write a test that would have caught the vulnerability. Ensure it passes with the fix.
7. Run all tests. Every test must pass.
8. Prepend to `progress.txt`. Use header format `## Session — YYYY-MM-DD HH:MM — Security: <vulnerability type>` (get current date/time from the system).
9. Mark the bug as fixed in prd.json. Commit your changes.

ONLY FIX ONE VULNERABILITY PER SESSION.

If no security issues remain, output <promise>COMPLETE</promise>.
