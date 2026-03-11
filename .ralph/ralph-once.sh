#!/usr/bin/env bash
# Ralph HITL (Human-In-The-Loop) — Single iteration
# Usage: .ralph/ralph-once.sh [--yolo] [prompt]
# Default prompt: implement. Options: implement, test, review
# --yolo: skip all permission prompts (fully autonomous)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Parse flags
YOLO=false
PROMPT=""
for arg in "$@"; do
  case "$arg" in
    --yolo) YOLO=true ;;
    *) PROMPT="$arg" ;;
  esac
done
PROMPT="${PROMPT:-implement}"
PROMPT_FILE="$SCRIPT_DIR/prompts/${PROMPT}.md"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Error: Prompt file not found: $PROMPT_FILE"
  echo "Available prompts: implement, test, review, qa"
  exit 1
fi

cd "$PROJECT_DIR"

PERMISSION_FLAG="--permission-mode acceptEdits"
if [ "$YOLO" = true ]; then
  PERMISSION_FLAG="--dangerously-skip-permissions"
  echo "=== Ralph YOLO — Prompt: $PROMPT ==="
else
  echo "=== Ralph HITL — Prompt: $PROMPT ==="
fi
echo "Project: $PROJECT_DIR"
echo ""

claude $PERMISSION_FLAG --chrome -p "$(cat "$PROMPT_FILE")" \
  --output-format stream-json --verbose | \
  "$SCRIPT_DIR/stream-format.sh"
