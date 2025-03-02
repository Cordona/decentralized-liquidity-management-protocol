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

run_coverage() {
  echo -e "\n${COLOR_YELLOW}Select coverage reporting mode:${COLOR_RESET}"
  echo "1) Basic coverage - no detailed report (default)"
  echo "2) Terminal report - select format"
  echo "3) File export - detailed report to coverage_report.txt"

  read -rp "Enter your choice (1-3, default is 1): " coverage_mode
  coverage_mode="${coverage_mode:-1}"  # Default to 1 if empty

  case "$coverage_mode" in
    1)
      log "INFO" "Running basic coverage..."
      forge coverage --ir-minimum
      ;;
    2)
      echo -e "\n${COLOR_YELLOW}Select report format:${COLOR_RESET}"
      echo "1) debug (default)"
      echo "2) summary"
      echo "3) lcov"
      echo "4) bytecode"

      read -rp "Enter format (1-4, default is 1): " format_choice
      format_choice="${format_choice:-1}"  # Default to 1 if empty

      case "$format_choice" in
        1) report_type="debug" ;;
        2) report_type="summary" ;;
        3) report_type="lcov" ;;
        4) report_type="bytecode" ;;
        *) 
          log "ERROR" "Invalid format. Using default 'debug'"
          report_type="debug"
          ;;
      esac

      log "INFO" "Running coverage with report type: $report_type"
      forge coverage --report "$report_type" --ir-minimum
      ;;
    3)
      log "INFO" "Exporting detailed coverage report..."
      forge coverage --report debug --ir-minimum > coverage_report.txt
      log "SUCCESS" "Coverage report exported to coverage_report.txt"
      ;;
    *)
      log "ERROR" "Invalid choice. Exiting."
      exit 1
      ;;
  esac
}

main() {
  validate_env
  run_coverage
}

main "$@"