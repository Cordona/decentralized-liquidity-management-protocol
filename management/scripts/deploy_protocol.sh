#!/usr/bin/env bash

set -euo pipefail  # Strict error handling

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"  
ENV_DIR="$ROOT_DIR/.env"  
DEPLOY_SCRIPT="script/deploy/Deploy.s.sol"  
DEPLOY_CONTRACT="Deploy"                   
SRC_DIR="$ROOT_DIR/src"

# Color Codes
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_PURPLE="\033[35m"

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

prompt_for_confirmation() {
  local expected_value="$1"
  local prompt_message="$2"

  while true; do
    read -rp "$prompt_message: " user_input
    if [[ "$user_input" == "$expected_value" ]]; then
      log "SUCCESS" "Confirmation received: $expected_value"
      break
    elif [[ "$user_input" == "exit" ]]; then
      log "WARN" "User cancelled the operation."
      exit 1
    else
      log "ERROR" "Invalid input. Please type '$expected_value' exactly or 'exit' to cancel."
    fi
  done
}

# 🔍 Validate Environment
validate_env() {
  log "INFO" "Validating environment..."
  for cmd in "cast" "forge" "slither" "aderyn"; do
    if ! command -v "$cmd" &> /dev/null; then
      log "ERROR" "Command '$cmd' is required but not installed."
      exit 1
    fi
  done
  if [[ ! -f "$ENV_DIR/sepolia.env" || ! -f "$ENV_DIR/mainnet.env" ]]; then
    log "ERROR" "Missing environment files in '$ENV_DIR'."
    exit 1
  fi
  log "SUCCESS" "Environment validated successfully."
}

# 🧪 Run Pre-Deployment Tests and Coverage Report
# 🧪 Run Pre-Deployment Tests and Coverage Report
run_tests_and_coverage() {
  local RECOMMENDED_COVERAGE=85
  local custom_coverage
  
  echo -e "\n${COLOR_GREEN}🚀 Protocol Deployment Pipeline${COLOR_RESET}"
  echo -e "\n${COLOR_YELLOW}Running Tests & Coverage Analysis...${COLOR_RESET}"
  echo ""

  # Prompt for custom coverage threshold
  echo -e "${COLOR_BLUE}Test Coverage Configuration${COLOR_RESET}"
  echo -e "Industry standard minimum coverage is ${COLOR_GREEN}85%${COLOR_RESET} for production protocols"
  read -rp "Enter your desired coverage threshold (recommended: 85%): " custom_coverage
  
  # Validate input and provide warnings for low coverage
  if ! [[ "$custom_coverage" =~ ^[0-9]+$ ]] || [ "$custom_coverage" -gt 100 ]; then
    log "ERROR" "Invalid coverage threshold. Using recommended value of ${RECOMMENDED_COVERAGE}%"
    custom_coverage=$RECOMMENDED_COVERAGE
  elif [ "$custom_coverage" -lt "$RECOMMENDED_COVERAGE" ]; then
    echo -e "\n${COLOR_RED}⚠️  WARNING: LOW COVERAGE THRESHOLD DETECTED ⚠️${COLOR_RESET}"
    echo -e "${COLOR_RED}You've selected a coverage threshold of ${custom_coverage}%, which is below the recommended ${RECOMMENDED_COVERAGE}%${COLOR_RESET}"
    echo -e "${COLOR_RED}Low test coverage increases risk of undetected bugs and security vulnerabilities${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}Consequences may include:${COLOR_RESET}"
    echo -e " - Undetected edge case vulnerabilities"
    echo -e " - Higher risk of funds loss in production"
    echo -e " - Potential reputational damage to protocol"
    echo ""
    
    # Require explicit acknowledgment
    prompt_for_confirmation "ACKNOWLEDGE LOW TEST COVERAGE RISK" "Type 'ACKNOWLEDGE LOW TEST COVERAGE RISK' to proceed with ${custom_coverage}% coverage threshold"
  fi
  
  local MIN_COVERAGE=$custom_coverage
  log "INFO" "Using coverage threshold: ${MIN_COVERAGE}%"

  eval "$(shell/load_env.sh "$ENV_DIR/test.env")"

  # Rest of your existing function...
  echo -e "\n${COLOR_BLUE}Executing Coverage Analysis...${COLOR_RESET}"
  local coverage_output
  if ! coverage_output=$(forge coverage --ir-minimum --report summary 2>&1); then
    echo -e "\n${COLOR_RED}Failed Tests:${COLOR_RESET}"
    echo "$coverage_output" | grep "\[FAIL" | sort -u | while read -r line; do
        echo "❌ $line"
    done
    log "ERROR" "Test execution failed!"
    exit 1
  fi

  # Extract the Total line and parse metrics 🔧
  local total_line
  total_line=$(echo "$coverage_output" | grep "Total")
  
  # Parse using more precise awk pattern matching
  local lines_coverage=$(echo "$total_line" | awk -F'|' '{print $3}' | grep -o '[0-9.]\+' | head -1)
  local statements_coverage=$(echo "$total_line" | awk -F'|' '{print $4}' | grep -o '[0-9.]\+' | head -1)
  local branches_coverage=$(echo "$total_line" | awk -F'|' '{print $5}' | grep -o '[0-9.]\+' | head -1)
  local functions_coverage=$(echo "$total_line" | awk -F'|' '{print $6}' | grep -o '[0-9.]\+' | head -1)

  # Display coverage report 📊
  echo -e "\n${COLOR_PURPLE}📊 Coverage Report:${COLOR_RESET}"
  echo ""
  echo "Lines........: ${lines_coverage}% (min: ${MIN_COVERAGE}%)"
  echo "Statements...: ${statements_coverage}% (min: ${MIN_COVERAGE}%)"
  echo "Branches.....: ${branches_coverage}% (min: ${MIN_COVERAGE}%)"
  echo "Functions....: ${functions_coverage}% (min: ${MIN_COVERAGE}%)"
  echo ""

  # Check coverage thresholds 🎯
  if (( $(echo "$lines_coverage < $MIN_COVERAGE" | bc -l) )) || \
     (( $(echo "$statements_coverage < $MIN_COVERAGE" | bc -l) )) || \
     (( $(echo "$branches_coverage < $MIN_COVERAGE" | bc -l) )) || \
     (( $(echo "$functions_coverage < $MIN_COVERAGE" | bc -l) )); then
    log "ERROR" "❌ Coverage requirements not met! (Minimum: ${MIN_COVERAGE}%)"
    exit 1
  fi

  log "SUCCESS" "✅ All tests passed and coverage requirements met!"
}

run_security_checks() {
  echo -e "\n${COLOR_YELLOW}Running Security Analysis Tools...${COLOR_RESET}"
  echo ""

  STATIC_ANALYSIS_SCRIPT="$(dirname "$0")/static_analysis.sh"

  if [[ ! -x "$STATIC_ANALYSIS_SCRIPT" ]]; then
    log "ERROR" "Missing or non-executable static analysis script: $STATIC_ANALYSIS_SCRIPT"
    exit 1
  fi

  # Run security analysis script (flags will be set inside)
  source "$STATIC_ANALYSIS_SCRIPT"

  if [[ "$SLITHER_FOUND_ISSUES" -eq 1 || "$ADERYN_FOUND_ISSUES" -eq 1 ]]; then
    while true; do
      echo ""
      read -rp "$(echo -e "${COLOR_YELLOW}Would you like to [1] Cancel deployment or [2] Continue with known issues? (1/2):${COLOR_RESET} ")" user_choice
      case "$user_choice" in
        1) 
          echo -e "${COLOR_PURPLE}🚫 Deployment cancelled due to security findings.${COLOR_RESET}"
          exit 0
          ;;
        2)
          log "INFO" "Please document known issues."
          read -rp "Enter description of known issues: " known_issues
          echo "$known_issues" >> known_security_issues.txt
          break
          ;;
        *)
          log "ERROR" "Invalid choice. Please enter 1 or 2."
          ;;
      esac
    done

    # 🔥 Require explicit risk acknowledgment before proceeding
    prompt_for_confirmation "ACKNOWLEDGE RISKS" "Type 'ACKNOWLEDGE RISKS' to proceed with deployment (or 'exit' to cancel)"
  else
    log "SUCCESS" "No critical security issues detected. Proceeding to deployment."
  fi
}

# 📜 Protocol Architecture Review
review_protocol_architecture() {
  echo -e "\n${COLOR_YELLOW}Protocol Architecture Review${COLOR_RESET}"
  echo ""

  for dir in "$SRC_DIR"/*/; do
    module_name=$(basename "$dir")
    contract_count=$(find "$dir" -name "*.sol" | wc -l | tr -d ' ')
    
    echo -e "\n${COLOR_YELLOW}${module_name} (${contract_count} contracts)${COLOR_RESET}"
    for file in "$dir"/*.sol; do
      if [[ -f "$file" ]]; then
        if [[ $(basename "$file") == I*.sol ]]; then
          echo "  ├─ $(basename "$file") (Interface)"
        else
          echo "  ├─ $(basename "$file")"
        fi
      fi
    done
  done
}

# 🚀 Select Deployment Network
select_network() {
  echo -e "\n${COLOR_YELLOW}Select deployment target:${COLOR_RESET}"
  echo "1) Sepolia Testnet"
  echo "2) Ethereum Mainnet"

  while true; do
    read -rp "Enter your choice (1-2): " choice
    case "$choice" in
      1) 
        NETWORK="Sepolia"
        ENV_FILE="$ENV_DIR/sepolia.env"
        break ;;
      2)
        NETWORK="Mainnet"
        ENV_FILE="$ENV_DIR/mainnet.env"
        prompt_for_confirmation "MAINNET" "⚠️ Type 'MAINNET' to confirm or 'exit' to cancel"
        break ;;
      *)
        log "ERROR" "Invalid choice. Please enter 1 or 2."
        ;;
    esac
  done

  log "INFO" "Selected network: $NETWORK"
  eval "$(shell/load_env.sh "$ENV_FILE")"

  review_protocol_architecture

  echo -e "\n${COLOR_RED}Pre-deployment Checklist:${COLOR_RESET}"
  if [[ "$NETWORK" == "Mainnet" ]]; then
    echo -e "${COLOR_PURPLE}⚠️  Ensure the deployer is a multisig wallet address! ⚠️${COLOR_RESET}"
  fi
  echo "  □ Verify contract parameters"
  echo "  □ Confirm network settings"
  echo "  □ Check wallet balance"
}

# 🔐 Select Keystore
select_keystore() {
  echo -e "\n${COLOR_YELLOW}Available keystores:${COLOR_RESET}"
  cast wallet list

  while true; do
    read -rp "Enter deployment keystore name: " KEYSTORE_NAME
    if [[ -f "$HOME/.foundry/keystores/$KEYSTORE_NAME" ]]; then
      break
    else
      log "ERROR" "Keystore '$KEYSTORE_NAME' not found!"
    fi
  done
}

execute_deployment() {
  # Prompt user for script location with default
  read -rp "Enter deployment script location (default: script/deploy/Deploy.s.sol): " user_deploy_script
  DEPLOY_SCRIPT="${user_deploy_script:-script/deploy/Deploy.s.sol}"

  # Prompt user for contract name with default
  read -rp "Enter contract name to deploy (default: Deploy): " user_deploy_contract
  DEPLOY_CONTRACT="${user_deploy_contract:-Deploy}"

  log "INFO" "Using deployment script: $DEPLOY_SCRIPT"
  log "INFO" "Using contract: $DEPLOY_CONTRACT"
  log "INFO" "Initiating deployment to $NETWORK..."

  select_keystore

  forge script "$DEPLOY_SCRIPT:$DEPLOY_CONTRACT" \
    --rpc-url "$RPC_URL" \
    --broadcast \
    --verify \
    --etherscan-api-key "$ETHERSCAN_API_KEY" \
    --keystore "$HOME/.foundry/keystores/$KEYSTORE_NAME" \
    -vvvv
}

main() {
  validate_env
  run_tests_and_coverage
  run_security_checks
  select_network
  execute_deployment
}

main "$@"