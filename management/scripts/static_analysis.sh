#!/usr/bin/env bash

set -euo pipefail  # Strict error handling

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"  

# Color Codes
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"

log() {
  local level="$1"
  local message="$2"
  local color=""

  case "$level" in
    "INFO") color="$COLOR_BLUE" ;;
    "SUCCESS") color="$COLOR_GREEN" ;;
    "ERROR") color="$COLOR_RED" ;;
    "WARN") color="$COLOR_YELLOW" ;;
  esac

  printf "${color}[%s] %s${COLOR_RESET}\n" "$level" "$message"
}

SLITHER_FOUND_ISSUES=0
ADERYN_FOUND_ISSUES=0

run_slither() {
  log "INFO" "Running Slither Security Analysis..."
  if slither . --config-file slither.config.json --checklist --show-ignored-findings; then
    log "SUCCESS" "No critical issues found by Slither!"
  else
    log "WARN" "Slither found issues. Review the report above."
    export SLITHER_FOUND_ISSUES=1
  fi
}

run_aderyn() {
  log "INFO" "Running Aderyn Security Analysis..."
  aderyn . > aderyn_output.txt 2>&1
  if [[ ! -s aderyn_output.txt ]]; then
    log "SUCCESS" "No critical issues found by Aderyn!"
  else
    log "WARN" "Aderyn found issues!"
    export ADERYN_FOUND_ISSUES=1
  fi
  rm -f aderyn_output.txt

  if [[ -f "report.md" ]]; then
    if grep -Eq '^## (H|M|L)-[0-9]+' report.md; then
      # Count issues by severity
      HIGH_COUNT=$(grep -Ec '^## H-[0-9]+' report.md 2>/dev/null) || HIGH_COUNT=0
      MEDIUM_COUNT=$(grep -Ec '^## M-[0-9]+' report.md 2>/dev/null) || MEDIUM_COUNT=0
      LOW_COUNT=$(grep -Ec '^## L-[0-9]+' report.md 2>/dev/null) || LOW_COUNT=0

      # Print High Issues if any
      if [[ "$HIGH_COUNT" -gt 0 ]]; then
        echo -e "\n${COLOR_RED}# High Issues ($HIGH_COUNT)${COLOR_RESET}"
        grep -E '^## H-[0-9]+' report.md | sed 's/^/  - /'
        log "ERROR" "High severity issues found."
      fi

      # Print Medium Issues if any
      if [[ "$MEDIUM_COUNT" -gt 0 ]]; then
        echo -e "\n${COLOR_YELLOW}# Medium Issues ($MEDIUM_COUNT)${COLOR_RESET}"
        grep -E '^## M-[0-9]+' report.md | sed 's/^/  - /'
      fi

      # Print Low Issues if any
      if [[ "$LOW_COUNT" -gt 0 ]]; then
        echo -e "\n${COLOR_BLUE}# Low Issues ($LOW_COUNT)${COLOR_RESET}"
        grep -E '^## L-[0-9]+' report.md | sed 's/^/  - /'
      fi

    else
      log "SUCCESS" "No security issues found in report.md."
    fi
  fi
}

main() {
  echo -e "\n${COLOR_YELLOW}Select Security Analysis Tool:${COLOR_RESET}"
  echo "1) Slither - Static analysis for Solidity vulnerabilities"
  echo "2) Aderyn - Smart contract security scanner"
  echo "3) All - Run both Slither and Aderyn"

  while true; do
    read -rp "Enter your choice (1-3): " choice
    case "$choice" in
      1) run_slither; break ;;
      2) run_aderyn; break ;;
      3) 
        run_slither
        run_aderyn
        break ;;
      *)
        log "ERROR" "Invalid choice. Please enter 1, 2, or 3."
        ;;
    esac
  done

  export SLITHER_FOUND_ISSUES
  export ADERYN_FOUND_ISSUES
}

main "$@"