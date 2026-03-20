#!/usr/bin/env bash
# Ralph HITL (Human-In-The-Loop) — Single iteration
# Usage: .ralph/ralph-once.sh [--yolo] [skill]
# Default skill: implement. Options: implement, test, review, refactor, docs, perf, security
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
  MODE="HITL"
  MODE_COLOR="$GREEN"
fi

echo -e "${BOLD}╭──────────────────────────────────────╮${RESET}"
echo -e "${BOLD}│${RESET}  ${CYAN}⚡${RESET} ${BOLD}Ralph${RESET} ${MODE_COLOR}${MODE}${RESET}                        ${BOLD}│${RESET}"
echo -e "${BOLD}│${RESET}  ${DIM}Skill: ${PROMPT}${RESET}$(printf '%*s' $((27 - ${#PROMPT})) '')${BOLD}│${RESET}"
echo -e "${BOLD}╰──────────────────────────────────────╯${RESET}"
echo -e "${DIM}  Project: $(basename "$PROJECT_DIR")${RESET}"
echo ""

claude $PERMISSION_FLAG --chrome -p "$(cat "$PROMPT_FILE")" \
  --output-format stream-json --verbose | \
  "$SCRIPT_DIR/stream-format.sh"
