# Effective Harness — Ralph Wiggum Loop for Claude Code

A scaffold for building products using the Ralph Wiggum Loop pattern — an agentic coding technique where Claude Code implements features autonomously in a loop, one task at a time.

Based on:
- [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) (Anthropic)
- [The Ralph Wiggum Loop](https://ghuntley.com/ralph/) (Geoffrey Huntley)
- [Getting Started with Ralph](https://www.aihero.dev/getting-started-with-ralph) (AI Hero)
- [Tips for AI Coding with Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum) (AI Hero)

## How It Works

Ralph treats development as a loop. Each iteration:

1. Claude reads the PRD and progress file
2. Selects the highest-priority incomplete task
3. Implements it fully (no stubs)
4. Runs tests and type checks
5. Updates progress, marks the task done, commits
6. Loop repeats until all tasks are complete

The key constraint: **one task per iteration**. This keeps context focused and creates clean git history with rollback points.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Git
- Docker Desktop 4.50+ (optional, for sandboxed execution)

## Quick Start

### 0. Run the Setup Wizard (Recommended)

```bash
.ralph/ralph-init.sh
```

Interactively generates `prd.json` and `.claude/CLAUDE.md` for your project. Skip this and configure manually if you prefer.

### 1. Define Your Product

Edit `prd.json` with your requirements. Use the template at `.ralph/templates/prd.example.json` as a reference.

```json
{
  "name": "Phase 1: Foundation",
  "tasks": [
    { "id": "1.1", "description": "Initialize Next.js project with TypeScript and Tailwind", "done": false },
    { "id": "1.2", "description": "Set up Prisma with SQLite for local development", "done": false },
    { "id": "1.3", "description": "Create User and Post data models", "done": false }
  ]
}
```

Write tasks that are **specific and scoped** — each should be completable in a single session. Include acceptance criteria when helpful.

### 2. Configure Your Stack

Update two files:

**`prd.json`** — Add your tech stack in the `tech_stack` object so Ralph knows what tools to use.

**`.claude/CLAUDE.md`** — Update the Tech Stack section. Add any project-specific conventions (naming, patterns, libraries to prefer/avoid).

### 3. Run Ralph (HITL Mode)

Start with human-in-the-loop to watch Ralph work and tune your prompts:

```bash
.ralph/ralph-once.sh
```

This runs a single iteration using the `implement` prompt. You can specify a different prompt:

```bash
.ralph/ralph-once.sh test     # test coverage iteration
.ralph/ralph-once.sh review   # code review iteration
```

Review the output. If Ralph goes off track, refine the prompt in `.ralph/prompts/implement.md` and run again. **This tuning phase is critical** — there are no perfect prompts, only prompts refined through observation.

### 4. Run Ralph (AFK Mode)

Once your prompts are tuned and the foundation is stable:

```bash
.ralph/ralph-loop.sh 10          # 10 iterations, local
.ralph/ralph-sandbox.sh 10       # 10 iterations, Docker sandbox
```

The loop exits early if Ralph outputs `<promise>COMPLETE</promise>` (all PRD tasks done).

**Iteration guidelines:**
- 5-10 iterations for small/focused work
- 20-30 for a full feature phase
- Always set a cap — never run unbounded loops with stochastic systems

## Project Structure

```
.
├── .claude/
│   └── CLAUDE.md              # Claude Code project instructions
├── .ralph/
│   ├── prompts/
│   │   ├── implement.md       # Feature implementation prompt
│   │   ├── test.md            # Test coverage prompt
│   │   └── review.md          # Code review prompt
│   ├── templates/
│   │   ├── prd.example.json    # Example PRD format
│   │   └── progress.example.txt
│   ├── ralph-once.sh          # HITL: single iteration
│   ├── ralph-loop.sh          # AFK: autonomous loop
│   └── ralph-sandbox.sh       # AFK: loop in Docker sandbox
├── src/                       # Application source code
├── tests/                     # Test files
├── prd.json                   # Product requirements (your tasks)
├── progress.txt               # Session-by-session progress log
└── .gitignore
```

### Key Files

| File | Purpose | Who writes it |
|------|---------|---------------|
| `prd.json` | Tasks, bugs, and requirements | You (Ralph marks tasks done) |
| `progress.txt` | What was done each session | Ralph |
| `.claude/CLAUDE.md` | Rules Ralph follows every session | You |

## Development Workflow

### Recommended Sequence

```
1. Define PRD          →  prd.json
2. HITL iterations     →  .ralph/ralph-once.sh        (tune prompts, build foundation)
3. AFK iterations      →  .ralph/ralph-loop.sh 10     (let Ralph build features)
4. Review + test loop  →  .ralph/ralph-once.sh review (find issues)
                       →  .ralph/ralph-once.sh test   (improve coverage)
5. Repeat from 3       →  until PRD is complete
```

### HITL vs AFK Decision

| Use HITL when... | Use AFK when... |
|---|---|
| Starting a new project | Foundation is solid and tested |
| Tuning prompts for the first time | Prompts produce consistent results |
| Risky architectural work | Tasks are well-scoped and lower-risk |
| Debugging Ralph's behavior | You want to step away |

### Writing Good PRD Tasks

**Good** — specific, scoped, testable:
```json
{ "id": "2.1", "description": "Create REST endpoint POST /api/users that validates email uniqueness and returns 201 with user object or 409 on duplicate", "done": false }
```

**Bad** — vague, multi-feature, no criteria:
```json
{ "id": "2.1", "description": "Build the user system", "done": false }
```

Tips:
- One feature per task
- Include acceptance criteria or verification steps
- Order tasks so dependencies come first
- If a task feels too big, split it into subtasks

### Customizing Prompts

All prompts live in `.ralph/prompts/`. The three included prompts cover the most common loops:

- **`implement.md`** — Pick a task, build it, test it, commit
- **`test.md`** — Find untested code, write tests, commit
- **`review.md`** — Find issues, log them in prd.json `bugs` array, fix one, commit

Create new prompts for specialized loops:

```bash
# Example: a prompt that only fixes linting errors
cp .ralph/prompts/implement.md .ralph/prompts/lint.md
# Edit lint.md with your linting-specific instructions
.ralph/ralph-loop.sh 5 lint
```

The loop is always the same — only the prompt changes.

### Recovery

If Ralph produces bad output:
- Check `git log` for the last good commit
- `git diff` to see what changed
- `git revert HEAD` or `git reset --hard <good-commit>` to recover
- Refine the prompt based on what went wrong
- Run again

Every iteration creates a commit, so you always have rollback points.

### Monitoring Progress

```bash
# What has Ralph done?
cat progress.txt

# What's left?
python3 -c "import json; [print(f\"{t['id']}: {t['description']}\") for p in json.load(open('prd.json'))['phases'] for t in p['tasks'] if not t['done']]"

# Any known bugs?
python3 -c "import json; [print(f\"{b['id']}: [{b['priority']}] {b['description']}\") for b in json.load(open('prd.json')).get('bugs',[]) if not b.get('fixed')]"

# Git history
git log --oneline
```

## Tips

- **Start small.** Get one task working end-to-end before scaling up iterations.
- **JSON PRDs are more robust** than markdown for large task lists (model is less likely to corrupt structured JSON).
- **Tune prompts in HITL mode.** Watch what Ralph does wrong and add explicit instructions to prevent it. Failures become prompt refinements.
- **Keep tasks atomic.** A task that takes 3+ iterations is too big — split it.
- **Use Docker sandbox for AFK.** Prevents accidental system changes when you're not watching.
- **Review after AFK runs.** Always check `git log`, `progress.txt`, and run tests after unattended loops.
- **Context rot is real.** If quality degrades in later iterations, the tasks may be too complex. Break them down further.
