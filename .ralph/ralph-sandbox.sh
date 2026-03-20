#!/usr/bin/env bash
# Ralph Sandboxed — Runs loop inside Docker sandbox for isolation
# Usage: .ralph/ralph-sandbox.sh <iterations> [skill]
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
  echo "Available skills: implement, test, review, refactor, docs, perf, security"
  exit 1
fi

cd "$PROJECT_DIR"

# Colors
if [ -t 1 ]; then
  BOLD='\033[1m' DIM='\033[2m' CYAN='\033[36m' YELLOW='\033[33m' GREEN='\033[32m' RESET='\033[0m'
else
  BOLD='' DIM='' CYAN='' YELLOW='' GREEN='' RESET=''
fi

echo -e "${BOLD}╭──────────────────────────────────────╮${RESET}"
echo -e "${BOLD}│${RESET}  ${CYAN}⚡${RESET} ${BOLD}Ralph${RESET} ${CYAN}Sandbox${RESET}                     ${BOLD}│${RESET}"
echo -e "${BOLD}│${RESET}  ${DIM}Skill: ${PROMPT}  ×  ${ITERATIONS} iterations${RESET}$(printf '%*s' $((16 - ${#PROMPT} - ${#ITERATIONS})) '')${BOLD}│${RESET}"
echo -e "${BOLD}╰──────────────────────────────────────╯${RESET}"
echo -e "${DIM}  Project: $(basename "$PROJECT_DIR")${RESET}"
echo ""

for ((i=1; i<=ITERATIONS; i++)); do
  echo -e "${BOLD}━━━ Iteration $i/$ITERATIONS ━━━${RESET}"

  RESULT_FILE=$(mktemp)
  docker sandbox run claude --permission-mode acceptEdits --chrome -p "$(cat "$PROMPT_FILE")" \
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
