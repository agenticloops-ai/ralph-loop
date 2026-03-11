#!/usr/bin/env bash
# Ralph AFK (Away From Keyboard) — Autonomous loop
# Usage: .ralph/ralph-loop.sh [--yolo] <iterations> [prompt]
# Default prompt: implement. Options: implement, test, review
# --yolo: skip all permission prompts (fully autonomous)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Parse flags and positional args
YOLO=false
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --yolo) YOLO=true ;;
    *) POSITIONAL+=("$arg") ;;
  esac
done

ITERATIONS="${POSITIONAL[0]:-}"
PROMPT="${POSITIONAL[1]:-implement}"
PROMPT_FILE="$SCRIPT_DIR/prompts/${PROMPT}.md"

if [ -z "$ITERATIONS" ]; then
  echo "Usage: $0 [--yolo] <iterations> [prompt]"
  echo "  --yolo:     skip all permission prompts (fully autonomous)"
  echo "  iterations: max number of loop iterations (e.g., 10)"
  echo "  prompt:     implement (default), test, review, qa"
  exit 1
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Error: Prompt file not found: $PROMPT_FILE"
  echo "Available prompts: implement, test, review, qa"
  exit 1
fi

cd "$PROJECT_DIR"

PERMISSION_FLAG="--permission-mode acceptEdits"
if [ "$YOLO" = true ]; then
  PERMISSION_FLAG="--dangerously-skip-permissions"
  echo "=== Ralph YOLO — Prompt: $PROMPT — Max iterations: $ITERATIONS ==="
else
  echo "=== Ralph AFK — Prompt: $PROMPT — Max iterations: $ITERATIONS ==="
fi
echo "Project: $PROJECT_DIR"
echo ""

for ((i=1; i<=ITERATIONS; i++)); do
  echo "--- Iteration $i/$ITERATIONS ---"

  RESULT_FILE=$(mktemp)
  claude $PERMISSION_FLAG --chrome -p "$(cat "$PROMPT_FILE")" \
    --output-format stream-json --verbose | \
    "$SCRIPT_DIR/stream-format.sh" "$RESULT_FILE"

  result=$(cat "$RESULT_FILE")
  rm -f "$RESULT_FILE"
  echo ""

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "=== PRD complete after $i iteration(s). ==="
    exit 0
  fi
done

echo "=== Reached max iterations ($ITERATIONS). Review progress.txt for status. ==="
