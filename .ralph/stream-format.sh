#!/usr/bin/env bash
# stream-format.sh — Format Claude Code stream-json events into readable terminal output
# Usage: claude -p ... --output-format stream-json --verbose | stream-format.sh [result_file]
#
# Reads NDJSON from stdin (claude --output-format stream-json --verbose)
# Prints human-readable progress to stderr (tool calls, status)
# Prints assistant text to stdout (streaming)
# If result_file is provided, also writes full assistant text there (for COMPLETE detection)
set -uo pipefail

RESULT_FILE="${1:-}"
FULL_TEXT=""

# Colors (only if terminal supports them)
if [ -t 2 ]; then
  DIM='\033[2m'
  CYAN='\033[36m'
  GREEN='\033[32m'
  YELLOW='\033[33m'
  RED='\033[31m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  DIM='' CYAN='' GREEN='' YELLOW='' RED='' BOLD='' RESET=''
fi

while IFS= read -r line; do
  # Skip empty lines
  [ -z "$line" ] && continue

  # Parse the top-level type
  msg_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null) || continue
  [ -z "$msg_type" ] && continue

  case "$msg_type" in
    system)
      subtype=$(echo "$line" | jq -r '.subtype // empty' 2>/dev/null)
      if [ "$subtype" = "init" ]; then
        session_id=$(echo "$line" | jq -r '.session_id // "unknown"' 2>/dev/null)
        echo -e "${DIM}Session: ${session_id}${RESET}" >&2
      fi
      ;;

    assistant)
      # Process each content block in the message
      content_count=$(echo "$line" | jq '.message.content | length' 2>/dev/null) || continue
      for ((j=0; j<content_count; j++)); do
        block_type=$(echo "$line" | jq -r ".message.content[$j].type // empty" 2>/dev/null)

        case "$block_type" in
          text)
            text=$(echo "$line" | jq -r ".message.content[$j].text // empty" 2>/dev/null)
            if [ -n "$text" ]; then
              echo "$text"
              FULL_TEXT="${FULL_TEXT}${text}"
            fi
            ;;

          tool_use)
            tool_name=$(echo "$line" | jq -r ".message.content[$j].name // \"unknown\"" 2>/dev/null)
            # Extract key argument based on tool type
            case "$tool_name" in
              Read)
                arg=$(echo "$line" | jq -r ".message.content[$j].input.file_path // empty" 2>/dev/null)
                echo -e "  ${CYAN}Read${RESET} ${DIM}${arg}${RESET}" >&2
                ;;
              Edit)
                arg=$(echo "$line" | jq -r ".message.content[$j].input.file_path // empty" 2>/dev/null)
                echo -e "  ${YELLOW}Edit${RESET} ${DIM}${arg}${RESET}" >&2
                ;;
              Write)
                arg=$(echo "$line" | jq -r ".message.content[$j].input.file_path // empty" 2>/dev/null)
                echo -e "  ${GREEN}Write${RESET} ${DIM}${arg}${RESET}" >&2
                ;;
              Bash)
                arg=$(echo "$line" | jq -r ".message.content[$j].input.command // empty" 2>/dev/null)
                # Truncate long commands
                if [ ${#arg} -gt 80 ]; then
                  arg="${arg:0:77}..."
                fi
                echo -e "  ${BOLD}Bash${RESET} ${DIM}${arg}${RESET}" >&2
                ;;
              Glob)
                arg=$(echo "$line" | jq -r ".message.content[$j].input.pattern // empty" 2>/dev/null)
                echo -e "  ${DIM}Glob${RESET} ${DIM}${arg}${RESET}" >&2
                ;;
              Grep)
                arg=$(echo "$line" | jq -r ".message.content[$j].input.pattern // empty" 2>/dev/null)
                echo -e "  ${DIM}Grep${RESET} ${DIM}${arg}${RESET}" >&2
                ;;
              Agent)
                arg=$(echo "$line" | jq -r ".message.content[$j].input.prompt // empty" 2>/dev/null)
                if [ ${#arg} -gt 80 ]; then
                  arg="${arg:0:77}..."
                fi
                echo -e "  ${CYAN}Agent${RESET} ${DIM}${arg}${RESET}" >&2
                ;;
              *)
                echo -e "  ${DIM}${tool_name}${RESET}" >&2
                ;;
            esac
            ;;
        esac
      done
      ;;

    user)
      # Tool results — show brief success/failure indicator
      content_count=$(echo "$line" | jq '.message.content | length' 2>/dev/null) || continue
      for ((j=0; j<content_count; j++)); do
        block_type=$(echo "$line" | jq -r ".message.content[$j].type // empty" 2>/dev/null)
        if [ "$block_type" = "tool_result" ]; then
          is_error=$(echo "$line" | jq -r ".message.content[$j].is_error // false" 2>/dev/null)
          if [ "$is_error" = "true" ]; then
            echo -e "  ${RED}  x failed${RESET}" >&2
          else
            echo -e "  ${GREEN}  ok${RESET}" >&2
          fi
        fi
      done
      ;;

    result)
      subtype=$(echo "$line" | jq -r '.subtype // "unknown"' 2>/dev/null)
      cost=$(echo "$line" | jq -r '.cost_usd // empty' 2>/dev/null)
      turns=$(echo "$line" | jq -r '.num_turns // empty' 2>/dev/null)
      duration=$(echo "$line" | jq -r '.duration_ms // empty' 2>/dev/null)

      echo "" >&2
      if [ "$subtype" = "success" ]; then
        echo -e "${GREEN}Done.${RESET}" >&2
      else
        echo -e "${RED}Finished with status: ${subtype}${RESET}" >&2
      fi

      # Print stats if available
      stats=""
      if [ -n "$turns" ]; then stats="${stats}${turns} turns"; fi
      if [ -n "$cost" ]; then
        [ -n "$stats" ] && stats="${stats}, "
        stats="${stats}\$${cost}"
      fi
      if [ -n "$duration" ]; then
        [ -n "$stats" ] && stats="${stats}, "
        # Convert ms to seconds
        secs=$(echo "scale=1; $duration / 1000" | bc 2>/dev/null || echo "${duration}ms")
        stats="${stats}${secs}s"
      fi
      if [ -n "$stats" ]; then
        echo -e "${DIM}${stats}${RESET}" >&2
      fi
      ;;
  esac
done

# Write accumulated text to result file if requested
if [ -n "$RESULT_FILE" ]; then
  echo "$FULL_TEXT" > "$RESULT_FILE"
fi
