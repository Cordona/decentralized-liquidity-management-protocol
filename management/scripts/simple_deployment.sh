#!/usr/bin/env bash

set -euo pipefail  # Strict error handling

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

# Step 1: Prompt for Deployment Script Path
get_deployment_script() {
  echo -e "\n${COLOR_YELLOW}Enter the absolute path to your deployment script:${COLOR_RESET}"
  read -rp "Path: " DEPLOY_SCRIPT

  while [[ ! -f "$DEPLOY_SCRIPT" ]]; do
    log "ERROR" "Invalid path. File not found!"
    read -rp "Enter a valid absolute path: " DEPLOY_SCRIPT
  done

  log "SUCCESS" "Deployment script set to: $DEPLOY_SCRIPT"
}

# Step 2: Prompt for Contract Name
get_contract_name() {
  echo -e "\n${COLOR_YELLOW}Enter the contract name to deploy (default: Deploy):${COLOR_RESET}"
  read -rp "Contract Name: " DEPLOY_CONTRACT
  DEPLOY_CONTRACT=${DEPLOY_CONTRACT:-Deploy}
  log "SUCCESS" "Deploying contract: $DEPLOY_CONTRACT"
}

# Step 3: Prompt for RPC URL
get_rpc_url() {
  echo -e "\n${COLOR_YELLOW}Enter the RPC URL for deployment:${COLOR_RESET}"
  read -rp "RPC URL: " RPC_URL

  while [[ -z "$RPC_URL" ]]; do
    log "ERROR" "RPC URL cannot be empty!"
    read -rp "Enter a valid RPC URL: " RPC_URL
  done

  log "SUCCESS" "Using RPC URL: $RPC_URL"
}

# Step 4: Prompt for Etherscan API Key
get_etherscan_key() {
  echo -e "\n${COLOR_YELLOW}Enter your Etherscan API Key for contract verification:${COLOR_RESET}"
  read -rp "Etherscan API Key: " ETHERSCAN_API_KEY

  while [[ -z "$ETHERSCAN_API_KEY" ]]; do
    log "ERROR" "Etherscan API Key cannot be empty!"
    read -rp "Enter a valid Etherscan API Key: " ETHERSCAN_API_KEY
  done

  log "SUCCESS" "Etherscan API Key received."
}

# Step 5: Display Available Keystores and Prompt for Selection
select_keystore() {
  echo -e "\n${COLOR_YELLOW}Available keystores:${COLOR_RESET}"
  cast wallet list

  while true; do
    read -rp "Enter keystore name for deployment: " KEYSTORE_NAME
    if [[ -f "$HOME/.foundry/keystores/$KEYSTORE_NAME" ]]; then
      log "SUCCESS" "Using keystore: $KEYSTORE_NAME"
      break
    else
      log "ERROR" "Keystore '$KEYSTORE_NAME' not found!"
    fi
  done
}

get_deployer_address() {
  echo -e "\n${COLOR_YELLOW}Enter the address that will deploy the contract:${COLOR_RESET}"
  read -rp "Deployer Address: " DEPLOYER_ADDRESS

  while [[ ! "$DEPLOYER_ADDRESS" =~ ^0x[a-fA-F0-9]{40}$ ]]; do
    log "ERROR" "Invalid Ethereum address format! Please enter a valid address."
    read -rp "Deployer Address: " DEPLOYER_ADDRESS
  done

  log "SUCCESS" "Using deployer address: $DEPLOYER_ADDRESS"
}

# Step 6: Final Confirmation Before Deployment
confirm_deployment() {
  echo -e "\n${COLOR_RED}⚠️ WARNING: You are about to use '$DEPLOY_CONTRACT' with the following settings:${COLOR_RESET}"
  echo -e "📜 Script: ${COLOR_PURPLE}$DEPLOY_SCRIPT${COLOR_RESET}"
  echo -e "🔗 RPC URL: ${COLOR_BLUE}$RPC_URL${COLOR_RESET}"
  echo -e "🔑 Keystore: ${COLOR_GREEN}$KEYSTORE_NAME${COLOR_RESET}"
  echo -e "🔍 Etherscan API Key: ${COLOR_YELLOW}[HIDDEN]${COLOR_RESET}"

  echo -e "\n${COLOR_YELLOW}Type 'PROCEED' to continue or 'exit' to cancel:${COLOR_RESET}"
  read -rp "Confirmation: " confirmation

  if [[ "$confirmation" != "PROCEED" ]]; then
    log "WARN" "Deployment cancelled by user."
    exit 1
  fi

  log "SUCCESS" "Proceeding with deployment!"
}

# Step 7: Execute Deployment
execute_deployment() {
  log "INFO" "Initiating deployment..."

  forge script "$DEPLOY_SCRIPT:$DEPLOY_CONTRACT" \
    --rpc-url "$RPC_URL" \
    --broadcast \
    --verify \
    --etherscan-api-key "$ETHERSCAN_API_KEY" \
    --keystore "$HOME/.foundry/keystores/$KEYSTORE_NAME" \
    --sender "$DEPLOYER_ADDRESS" \
    -vvvv

  log "SUCCESS" "Deployment process completed!"
}

# Main Execution Flow
main() {
  get_deployment_script
  get_contract_name
  get_rpc_url
  get_etherscan_key
  select_keystore
  get_deployer_address
  confirm_deployment
  execute_deployment
}

main "$@"