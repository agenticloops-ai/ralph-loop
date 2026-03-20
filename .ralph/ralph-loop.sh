#!/usr/bin/env bash
# Ralph AFK (Away From Keyboard) — Autonomous loop
# Usage: .ralph/ralph-loop.sh [--yolo] <iterations> [skill]
# Default skill: implement. Options: implement, test, review, refactor, docs, perf, security
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
  echo "Available skills: implement, test, review, refactor, docs, perf, security"
  exit 1
fi

cd "$PROJECT_DIR"

PERMISSION_FLAG="--permission-mode acceptEdits"

# Colors
if [ -t 1 ]; then
  BOLD='\033[1m' DIM='\033[2m' CYAN='\033[36m' YELLOW='\033[33m' GREEN='\033[32m' RESET='\033[0m'
else
  BOLD='' DIM='' CYAN='' YELLOW='' GREEN='' RESET=''
fi

# Banner
if [ "$YOLO" = true ]; then
  PERMISSION_FLAG="--dangerously-skip-permissions"
  MODE="YOLO"
  MODE_COLOR="$YELLOW"
else
  MODE="AFK"
  MODE_COLOR="$GREEN"
fi

echo -e "${BOLD}╭──────────────────────────────────────╮${RESET}"
echo -e "${BOLD}│${RESET}  ${CYAN}⚡${RESET} ${BOLD}Ralph${RESET} ${MODE_COLOR}${MODE}${RESET}                         ${BOLD}│${RESET}"
echo -e "${BOLD}│${RESET}  ${DIM}Skill: ${PROMPT}  ×  ${ITERATIONS} iterations${RESET}$(printf '%*s' $((16 - ${#PROMPT} - ${#ITERATIONS})) '')${BOLD}│${RESET}"
echo -e "${BOLD}╰──────────────────────────────────────╯${RESET}"
echo -e "${DIM}  Project: $(basename "$PROJECT_DIR")${RESET}"
echo ""

for ((i=1; i<=ITERATIONS; i++)); do
  echo -e "${BOLD}━━━ Iteration $i/$ITERATIONS ━━━${RESET}"

  RESULT_FILE=$(mktemp)
  claude $PERMISSION_FLAG --chrome -p "$(cat "$PROMPT_FILE")" \
    --output-format stream-json --verbose | \
    "$SCRIPT_DIR/stream-format.sh" "$RESULT_FILE"

  result=$(cat "$RESULT_FILE")
  rm -f "$RESULT_FILE"
  echo ""

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo -e "${GREEN}${BOLD}✔ PRD complete after $i iteration(s).${RESET}"
    exit 0
  fi
done

echo -e "${YELLOW}${BOLD}⚠ Reached max iterations ($ITERATIONS).${RESET} ${DIM}Review progress.txt for status.${RESET}"
