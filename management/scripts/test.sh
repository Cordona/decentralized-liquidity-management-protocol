#!/usr/bin/env bash

set -euo pipefail  # Strict error handling

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_DIR="$ROOT_DIR/.env"

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

validate_env() {
  log "INFO" "Loading environment variables..."
  eval "$(shell/load_env.sh "$ENV_DIR/test.env")"
}

run_tests() {
  echo -e "\n${COLOR_YELLOW}Select logging level for forge test:${COLOR_RESET}"
  echo "1) No logs (default)"
  echo "2) Minimal logs (-vvv)"
  echo "3) All logs (-vvvvv)"

  read -rp "Enter your choice (1-3, default is 1): " choice
  choice="${choice:-1}"  # Default to 1 if empty

  case "$choice" in
    1|"") LOG_LEVEL="" ;;
    2) LOG_LEVEL="-vvv" ;;
    3) LOG_LEVEL="-vvvvv" ;;
    *)
      log "ERROR" "Invalid choice. Exiting."
      exit 1
      ;;
  esac

  read -rp "Enter test name (press enter to run all tests): " test_name

  if [[ -n "$test_name" ]]; then
    log "INFO" "Running test: $test_name with log level: ${LOG_LEVEL:-none}"
    forge test $LOG_LEVEL --match-test "$test_name"
  else
    log "INFO" "Running all tests with log level: ${LOG_LEVEL:-none}"
    forge test $LOG_LEVEL
  fi
}

main() {
  validate_env
  run_tests
}

main "$@"