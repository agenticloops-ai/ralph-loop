#!/usr/bin/env bash
# Ralph Sandboxed — Runs loop inside Docker sandbox for isolation
# Usage: .ralph/ralph-sandbox.sh <iterations> [prompt]
# Requires: Docker Desktop 4.50+ with sandbox support
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROMPT="${2:-implement}"
PROMPT_FILE="$SCRIPT_DIR/prompts/${PROMPT}.md"

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <iterations> [prompt]"
  echo "  iterations: max number of loop iterations (e.g., 10)"
  echo "  prompt:     implement (default), test, review"
  exit 1
fi

ITERATIONS="$1"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Error: Prompt file not found: $PROMPT_FILE"
  echo "Available prompts: implement, test, review"
  exit 1
fi

cd "$PROJECT_DIR"

echo "=== Ralph Sandboxed — Prompt: $PROMPT — Max iterations: $ITERATIONS ==="
echo "Project: $PROJECT_DIR"
echo ""

for ((i=1; i<=ITERATIONS; i++)); do
  echo "--- Iteration $i/$ITERATIONS ---"

  RESULT_FILE=$(mktemp)
  docker sandbox run claude --permission-mode acceptEdits --chrome -p "$(cat "$PROMPT_FILE")" \
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
