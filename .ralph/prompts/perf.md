# Performance Optimization Prompt

You are optimizing this codebase for performance.

@prd.json @progress.txt

1. Read progress.txt and recent git log (`git log --oneline -10`) to understand current state.
2. Profile or analyze the codebase for the most impactful performance bottleneck. Look for:
   - N+1 queries or unnecessary database round-trips
   - Missing indexes on frequently queried fields
   - Unoptimized loops (O(n^2) where O(n) or O(n log n) is possible)
   - Large payload serialization or unnecessary data fetching
   - Missing caching for expensive computations or repeated lookups
   - Synchronous blocking where async/parallel execution is possible
   - Bundle size issues (unused imports, large dependencies)
3. **Measurement gate:** Before optimizing, establish a baseline. Write a benchmark test or add timing instrumentation so the improvement can be verified.
4. Implement the optimization. Keep changes minimal and focused on one bottleneck.
5. **Verification gate:** Run the benchmark again. If no measurable improvement, revert and try a different approach.
6. Run all tests. Every test must pass — performance gains must not break correctness.
7. Prepend to `progress.txt`. Use header format `## Session — YYYY-MM-DD HH:MM — Perf: <description>` (get current date/time from the system). Include before/after metrics.
8. Commit with a message describing the bottleneck and the measured improvement.

ONLY OPTIMIZE ONE BOTTLENECK PER SESSION.

If no significant performance bottlenecks remain, output <promise>COMPLETE</promise>.
