#!/usr/bin/env bash

set -euo pipefail  # Strict error handling

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"  
ENV_DIR="$ROOT_DIR/.env"
ACTIVATE_SCRIPT="script/activate/ActivateProtocol.s.sol"
ACTIVATE_CONTRACT="ActivateProtocol"
TMP_ENV_FILE="/tmp/activation_env_$$"  # Temporary env file with process ID

# Color codes (matching your deployment script)
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_PURPLE="\033[35m"

# Utility functions (reused from deployment script)
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
  for cmd in "cast" "forge" "jq"; do
    if ! command -v "$cmd" &> /dev/null; then
      log "ERROR" "Command '$cmd' is required but not installed."
      exit 1
    fi
  done
  log "SUCCESS" "Environment validated successfully."
}

# 📝 Discover Protocol Contracts
discover_contracts() {
  echo -e "\n${COLOR_GREEN}🔍 Protocol Contract Discovery${COLOR_RESET}"
  
  echo -e "\n${COLOR_YELLOW}Select discovery method:${COLOR_RESET}"
  echo "1) Specify path to run-latest.json"
  echo "2) Enter contract addresses manually"
  echo "3) Auto-discover from default locations"
  
  while true; do
    read -rp "Your choice (1-3): " discovery_choice
    case "$discovery_choice" in
      1) 
        discover_from_json
        break ;;
      2)
        discover_manual_entry
        break ;;
      3)
        discover_auto
        break ;;
      *)
        log "ERROR" "Invalid choice. Please enter 1-3."
        ;;
    esac
  done
  
  # Verify discovered addresses
  if [[ -z "$PROTOCOL_MANAGER" || -z "$V2_FACTORY" || -z "$V3_FACTORY" || -z "$PROTOCOL_TOKEN" ]]; then
    log "ERROR" "Failed to discover all required contract addresses"
    exit 1
  fi
  
  # Write discovered addresses to env file
  echo "DEPLOYED_PROTOCOL_MANAGER_ADDR=$PROTOCOL_MANAGER" >> "$TMP_ENV_FILE"
  echo "DEPLOYED_V2_PROTOCOL_FACTORY_ADDR=$V2_FACTORY" >> "$TMP_ENV_FILE"
  echo "DEPLOYED_V3_PROTOCOL_FACTORY_ADDR=$V3_FACTORY" >> "$TMP_ENV_FILE"
  echo "PROTOCOL_TOKEN_ADDRESS=$PROTOCOL_TOKEN" >> "$TMP_ENV_FILE"
  
  log "SUCCESS" "Contract discovery complete"
  echo -e "\n${COLOR_PURPLE}Discovered Contracts:${COLOR_RESET}"
  echo "Protocol Token: $PROTOCOL_TOKEN"
  echo "Protocol Manager: $PROTOCOL_MANAGER"
  echo "V2 Factory: $V2_FACTORY"
  echo "V3 Factory: $V3_FACTORY"
}

discover_from_json() {
  while true; do
    read -rp "Enter path to run-latest.json: " json_path
    if [[ -f "$json_path" ]]; then
      if ! command -v jq &> /dev/null; then
        log "ERROR" "jq is required to parse JSON files"
        exit 1
      fi
      
      # Extract addresses from JSON - adjust paths based on your JSON structure
      if ! PROTOCOL_TOKEN=$(jq -r '.transactions[] | select(.contractName=="ProtocolToken") | .contractAddress' "$json_path" 2>/dev/null | head -1); then
        log "ERROR" "Could not extract Protocol Token address from JSON"
        continue
      fi
      
      if ! PROTOCOL_MANAGER=$(jq -r '.transactions[] | select(.contractName=="ProtocolManager") | .contractAddress' "$json_path" 2>/dev/null | head -1); then
        log "ERROR" "Could not extract Protocol Manager address from JSON"
        continue
      fi
      
      if ! V2_FACTORY=$(jq -r '.transactions[] | select(.contractName=="UniswapV2PoolFactory") | .contractAddress' "$json_path" 2>/dev/null | head -1); then
        log "ERROR" "Could not extract V2 Factory address from JSON"
        continue
      fi
      
      if ! V3_FACTORY=$(jq -r '.transactions[] | select(.contractName=="UniswapV3PoolFactory") | .contractAddress' "$json_path" 2>/dev/null | head -1); then
        log "ERROR" "Could not extract V3 Factory address from JSON"
        continue
      fi
      
      # Validate addresses (basic format check)
      if [[ ! "$PROTOCOL_TOKEN" =~ ^0x[a-fA-F0-9]{40}$ || 
            ! "$PROTOCOL_MANAGER" =~ ^0x[a-fA-F0-9]{40}$ || 
            ! "$V2_FACTORY" =~ ^0x[a-fA-F0-9]{40}$ ||
            ! "$V3_FACTORY" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        log "ERROR" "Invalid address format found in JSON"
        continue
      fi
      
      break
    else
      log "ERROR" "File not found: $json_path"
    fi
  done
}

discover_manual_entry() {
  # Manually collect addresses with validation
  while true; do
    read -rp "Enter Protocol Token address: " PROTOCOL_TOKEN
    if [[ "$PROTOCOL_TOKEN" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
      break
    else
      log "ERROR" "Invalid address format. Must be a valid Ethereum address."
    fi
  done
  
  while true; do
    read -rp "Enter Protocol Manager address: " PROTOCOL_MANAGER
    if [[ "$PROTOCOL_MANAGER" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
      break
    else
      log "ERROR" "Invalid address format. Must be a valid Ethereum address."
    fi
  done
  
  while true; do
    read -rp "Enter V2 Factory address: " V2_FACTORY
    if [[ "$V2_FACTORY" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
      break
    else
      log "ERROR" "Invalid address format. Must be a valid Ethereum address."
    fi
  done
  
  while true; do
    read -rp "Enter V3 Factory address: " V3_FACTORY
    if [[ "$V3_FACTORY" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
      break
    else
      log "ERROR" "Invalid address format. Must be a valid Ethereum address."
    fi
  done
}

discover_auto() {
  log "INFO" "Searching for deployment artifacts in common locations..."
  
  # Define common locations to check
  local locations=(
    "./broadcast"
    "./out"
    "./deployments"
  )
  
  local found=false
  
  for location in "${locations[@]}"; do
    if [[ -d "$location" ]]; then
      # Find the most recent run-latest.json (this is simplified and would need refinement)
      local latest_json=$(find "$location" -name "run-latest.json" -type f -print0 | xargs -0 ls -t | head -1)
      
      if [[ -n "$latest_json" ]]; then
        log "INFO" "Found artifact: $latest_json"
        # Use the JSON discovery function with the found file
        json_path="$latest_json"
        discover_from_json
        found=true
        break
      fi
    fi
  done
  
  if [[ "$found" == "false" ]]; then
    log "ERROR" "No deployment artifacts found automatically. Please specify manually."
    discover_manual_entry
  fi
}

collect_activation_parameters() {
  echo -e "\n${COLOR_GREEN}📝 Activation Parameter Collection${COLOR_RESET}"

   # Step 1: Collect Admin Address
  collect_admin_address
  
  # Step 2: Collect Token Configuration (pair token & recipient)
  collect_token_configuration
  
  # Step 3: Collect Liquidity Parameters
  collect_liquidity_parameters
  
  # Step 4: Collect Technical Parameters
  collect_technical_parameters
  
  # Step 5: Define Activation Scope (what features to enable)
  define_activation_scope
  
  # Step 6: Collect UNCX Liquidity Locker Fee (if needed)
  collect_liquidity_locker_fee
  
  log "SUCCESS" "All activation parameters collected successfully"
}

# Admin who will execute the activation
collect_admin_address() {
  echo -e "\n${COLOR_YELLOW}[1/5] Admin Configuration${COLOR_RESET}"
  
  # Get keystore information if available
  local keystores=$(cast wallet list 2>/dev/null || echo "")
  
  if [[ -n "$keystores" ]]; then
    echo -e "${COLOR_BLUE}Available keystores:${COLOR_RESET}"
    echo "$keystores"
    echo ""
  fi
  
  while true; do
    read -rp "Enter admin address (with ADMIN_ROLE): " ADMIN_ADDRESS
    
    if [[ "$ADMIN_ADDRESS" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
      echo "ADMIN=$ADMIN_ADDRESS" >> "$TMP_ENV_FILE"
      break
    else
      log "ERROR" "Invalid Ethereum address format"
    fi
  done
  
  log "INFO" "Admin address set to: $ADMIN_ADDRESS"
  echo -e "${COLOR_PURPLE}⚠️ IMPORTANT: This address must have the ADMIN_ROLE to execute activation${COLOR_RESET}"
}

# Token addresses configuration (now without protocol token prompt)
collect_token_configuration() {
  echo -e "\n${COLOR_YELLOW}[2/5] Token Configuration${COLOR_RESET}"
  
  # Display discovered protocol token
  echo -e "${COLOR_BLUE}Using discovered Protocol Token: $PROTOCOL_TOKEN${COLOR_RESET}"
  
  # Pair Token Address
  while true; do
    read -rp "Enter Pair Token address (e.g. USDC): " PAIR_TOKEN_ADDRESS
    
    if [[ "$PAIR_TOKEN_ADDRESS" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
      echo "PAIR_TOKEN_ADDRESS=$PAIR_TOKEN_ADDRESS" >> "$TMP_ENV_FILE"
      break
    else
      log "ERROR" "Invalid Pair Token address format"
    fi
  done
  
  # WETH Address - provide a default
  local default_weth="0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2" # Mainnet WETH
  
  echo -e "${COLOR_BLUE}Default WETH address: $default_weth (Mainnet)${COLOR_RESET}"
  read -rp "Enter WETH address [press Enter for default]: " WETH_ADDRESS
  
  if [[ -z "$WETH_ADDRESS" ]]; then
    WETH_ADDRESS="$default_weth"
    log "INFO" "Using default WETH address"
  elif ! [[ "$WETH_ADDRESS" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
    log "ERROR" "Invalid WETH address format, using default instead"
    WETH_ADDRESS="$default_weth"
  fi
  
  echo "WETH_ADDR=$WETH_ADDRESS" >> "$TMP_ENV_FILE"
  
  # Liquidity Tokens Recipient
  while true; do
    read -rp "Enter Liquidity Tokens Recipient address: " LIQUIDITY_RECIPIENT
    
    if [[ "$LIQUIDITY_RECIPIENT" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
      echo "LIQUIDITY_RECIPIENT=$LIQUIDITY_RECIPIENT" >> "$TMP_ENV_FILE"
      break
    else
      log "ERROR" "Invalid Liquidity Recipient address format"
    fi
  done
}

# Liquidity amount configuration
collect_liquidity_parameters() {
  echo -e "\n${COLOR_YELLOW}[3/5] Liquidity Configuration${COLOR_RESET}"
  echo -e "${COLOR_PURPLE}NOTE: Token amounts are in token units (not wei)${COLOR_RESET}"
  
  # Protocol Token Liquidity
  while true; do
    read -rp "Enter Protocol Token liquidity amount(per pool): " TOKEN_LIQUIDITY
    
    if [[ "$TOKEN_LIQUIDITY" =~ ^[0-9]+$ ]]; then
      echo "PROTOCOL_TOKEN_LIQUIDITY=$TOKEN_LIQUIDITY" >> "$TMP_ENV_FILE"
      break
    else
      log "ERROR" "Invalid number format. Please enter a whole number."
    fi
  done
  
  # Pair Token Liquidity
  while true; do
    read -rp "Enter Pair Token liquidity amount (per pool): " PAIR_LIQUIDITY
    
    if [[ "$PAIR_LIQUIDITY" =~ ^[0-9]+$ ]]; then
      echo "PAIR_TOKEN_LIQUIDITY=$PAIR_LIQUIDITY" >> "$TMP_ENV_FILE"
      break
    else
      log "ERROR" "Invalid number format. Please enter a whole number."
    fi
  done
  
  # WETH Liquidity
  while true; do
    read -rp "Enter WETH liquidity amount (in ETH, not wei, per pool): " WETH_LIQUIDITY
    
    if [[ "$WETH_LIQUIDITY" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      echo "WETH_LIQUIDITY=$WETH_LIQUIDITY" >> "$TMP_ENV_FILE"
      break
    else
      log "ERROR" "Invalid number format. Please enter a decimal number."
    fi
  done
}

# Technical parameters (fee, deadline)
collect_technical_parameters() {
  echo -e "\n${COLOR_YELLOW}[4/5] Technical Parameters${COLOR_RESET}"
  
  # Fee Tier (for Uniswap V3)
  echo -e "${COLOR_BLUE}Uniswap V3 Fee Tiers:${COLOR_RESET}"
  echo "1) 0.01% (100) - Best for stable pairs"
  echo "2) 0.05% (500) - Best for stable pairs"
  echo "3) 0.3% (3000) - Best for most token pairs [DEFAULT]"
  echo "4) 1% (10000) - Best for exotic pairs"
  
  local DEFAULT_FEE=3000
  read -rp "Select fee tier (1-4) [press Enter for default (3)]: " FEE_CHOICE
  
  case "$FEE_CHOICE" in
    1) V3_POOL_FEE=100 ;;
    2) V3_POOL_FEE=500 ;;
    3) V3_POOL_FEE=3000 ;;
    4) V3_POOL_FEE=10000 ;;
    "") V3_POOL_FEE="$DEFAULT_FEE"; log "INFO" "Using default fee tier: 0.3%" ;;
    *) log "WARN" "Invalid selection, using default fee tier (0.3%)"; V3_POOL_FEE="$DEFAULT_FEE" ;;
  esac

  echo "V3_POOL_FEE=$V3_POOL_FEE" >> "$TMP_ENV_FILE"
  
  # Transaction Deadline (in seconds from now)
  local DEFAULT_DEADLINE=3600 # 1 hour
  
  echo -e "${COLOR_BLUE}Transaction Deadline:${COLOR_RESET}"
  echo "Time in seconds before transaction expires. Default: 3600 (1 hour)"
  
  read -rp "Enter deadline in seconds [press Enter for default]: " DEADLINE
  
  if [[ -z "$DEADLINE" ]]; then
    DEADLINE="$DEFAULT_DEADLINE"
    log "INFO" "Using default deadline: 1 hour"
  elif ! [[ "$DEADLINE" =~ ^[0-9]+$ ]]; then
    log "WARN" "Invalid deadline format, using default 1 hour"
    DEADLINE="$DEFAULT_DEADLINE"
  fi
  
  echo "DEADLINE=$DEADLINE" >> "$TMP_ENV_FILE"
}

# Activation scope (which features to enable)
define_activation_scope() {
  echo -e "\n${COLOR_YELLOW}[5/5] Activation Scope${COLOR_RESET}"
  echo -e "${COLOR_PURPLE}Select which protocol features to activate:${COLOR_RESET}"
  
  # Create V2 Pools
  read -rp "Create Uniswap V2 pools? (y/n): " CREATE_V2_POOLS_INPUT
  if [[ "$CREATE_V2_POOLS_INPUT" =~ ^[Yy]$ ]]; then
    CREATE_V2_POOLS=true
  else
    CREATE_V2_POOLS=false
  fi
  echo "CREATE_V2_POOLS=$CREATE_V2_POOLS" >> "$TMP_ENV_FILE"
  
  # Create V3 Pools
  read -rp "Create Uniswap V3 pools? (y/n): " CREATE_V3_POOLS_INPUT
  if [[ "$CREATE_V3_POOLS_INPUT" =~ ^[Yy]$ ]]; then
    CREATE_V3_POOLS=true
  else
    CREATE_V3_POOLS=false
  fi
  echo "CREATE_V3_POOLS=$CREATE_V3_POOLS" >> "$TMP_ENV_FILE"
  
  # Lock V2 Liquidity
  if [[ "$CREATE_V2_POOLS" == "true" ]]; then
    read -rp "Lock Uniswap V2 liquidity? (y/n): " LOCK_V2_LIQUIDITY_INPUT
    if [[ "$LOCK_V2_LIQUIDITY_INPUT" =~ ^[Yy]$ ]]; then
      LOCK_V2_LIQUIDITY=true
    else
      LOCK_V2_LIQUIDITY=false
    fi
  else
    log "INFO" "V2 Pools disabled - skipping liquidity locking configuration"
    LOCK_V2_LIQUIDITY=false
  fi
  echo "LOCK_V2_LIQUIDITY=$LOCK_V2_LIQUIDITY" >> "$TMP_ENV_FILE"
  
  # Summarize activation scope
  echo -e "\n${COLOR_BLUE}Activation Scope Summary:${COLOR_RESET}"
  echo "✅ Create V2 Pools: $CREATE_V2_POOLS"
  echo "✅ Create V3 Pools: $CREATE_V3_POOLS"
  echo "✅ Lock V2 Liquidity: $LOCK_V2_LIQUIDITY"
}

# Collect locker fee if V2 liquidity locking is enabled
collect_liquidity_locker_fee() {
  if [[ "$LOCK_V2_LIQUIDITY" != "true" || "$CREATE_V2_POOLS" != "true" ]]; then
    # Set a default value even when not using locking (to avoid env var errors)
    echo "LIQUIDITY_LOCKER_FLAT_FEE=0" >> "$TMP_ENV_FILE"
    return
  fi
  
  echo -e "\n${COLOR_YELLOW}UNCX Liquidity Locker Fee Configuration${COLOR_RESET}"
  
  # Set default based on chain ID
  local default_fee="0.1"
  if [[ "$CHAIN_ID" == "11155111" ]]; then
    default_fee="0.01"
  fi
  
  # Provide verification command to check actual fee
  echo -e "${COLOR_PURPLE}⚠️ IMPORTANT: UNCX fees may change. To verify current fee:${COLOR_RESET}"
  echo -e "${COLOR_BLUE}cast call 0x3075530A0524c2cAeb80Ac44A2cBAd15C82eb946 \"gFees()(uint256,address,uint256,uint256,uint256,uint256,address,uint256,uint256)\" --rpc-url <YOUR_RPC_URL>${COLOR_RESET}"
  echo -e "${COLOR_PURPLE}The first value returned is the ethFee (in wei)${COLOR_RESET}\n"
  
  # Collect fee from user
  read -rp "Enter UNCX liquidity locking fee in ETH [default: $default_fee]: " LIQUIDITY_LOCKER_FEE
  
  if [[ -z "$LIQUIDITY_LOCKER_FEE" ]]; then
    LIQUIDITY_LOCKER_FEE="$default_fee"
    log "INFO" "Using default UNCX fee: $default_fee ETH"
  elif ! [[ "$LIQUIDITY_LOCKER_FEE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    log "WARN" "Invalid fee format, using default $default_fee ETH"
    LIQUIDITY_LOCKER_FEE="$default_fee"
  fi
  
 # Convert ETH to wei (multiply by 10^18) and ensure it's an integer
  local locker_fee_wei=$(echo "scale=0; ${LIQUIDITY_LOCKER_FEE} * 10^18 / 1" | bc)
  echo "LIQUIDITY_LOCKER_FLAT_FEE=$locker_fee_wei" >> "$TMP_ENV_FILE"
  
  # Calculate total fee impact
  local total_fee=$(echo "$LIQUIDITY_LOCKER_FEE * 2" | bc)
  log "INFO" "Total locker fees: $total_fee ETH (for 2 pools)"
}

validate_activation_requirements() {
  echo -e "\n${COLOR_GREEN}🔎 Pre-Activation Validation${COLOR_RESET}"

  local all_checks_passed=true
  
  display_configuration_summary
   
  # Final validation result
  if [[ "$all_checks_passed" == "true" ]]; then
    echo -e "\n${COLOR_GREEN}✅ All pre-activation checks passed!${COLOR_RESET}"
  else
    echo -e "\n${COLOR_RED}❌ Some checks failed. Please resolve issues before proceeding.${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}Type 'PROCEED-ANYWAY' to continue despite warnings, or press Enter to abort:${COLOR_RESET}"
    read -r override
    if [[ "$override" != "PROCEED-ANYWAY" ]]; then
      log "INFO" "Activation aborted by user."
      exit 1
    fi
    log "WARN" "Proceeding with activation despite warnings."
  fi
}

# Function to display a comprehensive configuration summary
display_configuration_summary() {
  echo -e "\n${COLOR_GREEN}📋 COMPLETE ACTIVATION CONFIGURATION${COLOR_RESET}"

  # DISCOVERED CONTRACTS SECTION
  echo -e "${COLOR_PURPLE}■ DISCOVERED CONTRACTS${COLOR_RESET}"
  echo -e "  • Protocol Token:       ${COLOR_BLUE}$PROTOCOL_TOKEN${COLOR_RESET}"
  echo -e "  • Protocol Manager:     ${COLOR_BLUE}$PROTOCOL_MANAGER${COLOR_RESET}"
  echo -e "  • V2 Factory:           ${COLOR_BLUE}$V2_FACTORY${COLOR_RESET}"
  echo -e "  • V3 Factory:           ${COLOR_BLUE}$V3_FACTORY${COLOR_RESET}\n"
  
  # USER CONFIGURATION SECTION
  echo -e "${COLOR_PURPLE}■ USER CONFIGURATION${COLOR_RESET}"
  echo -e "  • Admin Address:        ${COLOR_BLUE}$ADMIN_ADDRESS${COLOR_RESET}"
  echo -e "  • Pair Token:           ${COLOR_BLUE}$PAIR_TOKEN_ADDRESS${COLOR_RESET}"
  echo -e "  • WETH Address:         ${COLOR_BLUE}$WETH_ADDRESS${COLOR_RESET}"
  echo -e "  • Liquidity Recipient:  ${COLOR_BLUE}$LIQUIDITY_RECIPIENT${COLOR_RESET}\n"
  
  # LIQUIDITY AMOUNTS SECTION
  echo -e "${COLOR_PURPLE}■ LIQUIDITY AMOUNTS${COLOR_RESET}"
  echo -e "  • Protocol Token:       ${COLOR_BLUE}$TOKEN_LIQUIDITY${COLOR_RESET}"
  echo -e "  • Pair Token:           ${COLOR_BLUE}$PAIR_LIQUIDITY${COLOR_RESET}"
  echo -e "  • WETH:                 ${COLOR_BLUE}$WETH_LIQUIDITY${COLOR_RESET}\n"
  
  # TECHNICAL PARAMETERS SECTION
  echo -e "${COLOR_PURPLE}■ TECHNICAL PARAMETERS${COLOR_RESET}"
  echo -e "  • Fee Tier:             ${COLOR_BLUE}$V3_POOL_FEE ($(get_fee_tier_name))${COLOR_RESET}"
  echo -e "  • Transaction Deadline: ${COLOR_BLUE}$DEADLINE seconds${COLOR_RESET}\n"
  
  # ACTIVATION SCOPE SECTION
  echo -e "${COLOR_PURPLE}■ ACTIVATION SCOPE${COLOR_RESET}"
  echo -e "  • Create V2 Pools:      ${COLOR_BLUE}$CREATE_V2_POOLS${COLOR_RESET}"
  echo -e "  • Create V3 Pools:      ${COLOR_BLUE}$CREATE_V3_POOLS${COLOR_RESET}"
  echo -e "  • Lock V2 Liquidity:    ${COLOR_BLUE}$LOCK_V2_LIQUIDITY${COLOR_RESET}\n"
  
  # VALIDATION INFORMATION SECTION
  echo -e "${COLOR_PURPLE}■ ON-CHAIN VALIDATION INFORMATION${COLOR_RESET}"
  echo ""
  echo -e "  ${COLOR_YELLOW}The following validations will be performed by the smart contract:${COLOR_RESET}\n"
  echo -e "  • Protocol Status:      Must not be already activated"
  echo -e "  • Admin Role:           Caller must have ADMIN_ROLE"
  echo -e "  • Token Balances:       Admin must have sufficient tokens for liquidity"
  echo -e "  • Token Approvals:      Tokens must be approved to relevant contracts"
  echo -e "  • ETH for Gas:          Transaction will require ETH for gas costs\n"
  
  echo -e "  ${COLOR_YELLOW}⚠️  NOTE: If any validation fails, the transaction will revert${COLOR_RESET}"
  echo -e "  ${COLOR_YELLOW}⚠️  Ensure all requirements are met before proceeding${COLOR_RESET}\n"

  # EXTERNAL FEES SECTION - NEW!
  if [[ "$LOCK_V2_LIQUIDITY" == "true" && "$CREATE_V2_POOLS" == "true" ]]; then
    echo -e "${COLOR_PURPLE}■ EXTERNAL FEES${COLOR_RESET}"
    echo -e "  ${COLOR_RED}⚠️  WARNING: UNCX LIQUIDITY LOCKING REQUIRES FEES${COLOR_RESET}"
    echo -e "  ${COLOR_RED}⚠️  $LIQUIDITY_LOCKER_FEE ETH required per pool lock (total: $(echo "$LIQUIDITY_LOCKER_FEE * 2" | bc) ETH)${COLOR_RESET}"
    echo -e "  ${COLOR_RED}⚠️  This fee is paid to UNCX Network, not to the protocol${COLOR_RESET}"
  if [[ "$CHAIN_ID" == "1" ]]; then
    echo -e "  ${COLOR_YELLOW}⚠️  WARNING: Mainnet fees may be higher than testnet fees${COLOR_RESET}"
  fi
  echo ""
fi
}

# Helper function to get fee tier name
get_fee_tier_name() {
  case "$V3_POOL_FEE" in
    100) echo "0.01% - Stable Pairs" ;;
    500) echo "0.05% - Stable Pairs" ;;
    3000) echo "0.3% - Standard Pairs" ;;
    10000) echo "1% - Exotic Pairs" ;;
    *) echo "Custom" ;;
  esac
}

execute_activation() {
  echo -e "\n${COLOR_GREEN}🚀 Protocol Activation Execution${COLOR_RESET}"  
  echo ""
  # Final confirmation
  echo -e "${COLOR_RED}⚠️  FINAL WARNING: Protocol activation is a one-time operation${COLOR_RESET}"
  echo -e "${COLOR_RED}⚠️  Once activated, the protocol cannot be activated again${COLOR_RESET}\n"
  
  prompt_for_confirmation "ACTIVATE-PROTOCOL" "Type 'ACTIVATE-PROTOCOL' to proceed with activation"
  
  # Locate activation script
  locate_activation_script
  
  # Select keystore
  select_keystore
  
  # Execute activation
  echo -e "\n${COLOR_YELLOW}Activating protocol...${COLOR_RESET}"
  
  # Export all variables to environment for forge script
  export $(cat "$TMP_ENV_FILE" | xargs)

  if forge script "$ACTIVATION_SCRIPT:$ACTIVATION_CONTRACT" \
    --rpc-url "$RPC_URL" \
    --broadcast \
    --keystore "$HOME/.foundry/keystores/$KEYSTORE_NAME"; then
    
    echo -e "\n${COLOR_GREEN}🎉 Protocol successfully activated!${COLOR_RESET}"
    echo -e "Transaction details available in the forge output above."
  else
    echo -e "\n${COLOR_RED}❌ Protocol activation failed.${COLOR_RESET}"
    echo -e "Please check the error messages above for details."
  fi
}

# Find the activation script file
locate_activation_script() {
  echo -e "\n${COLOR_YELLOW}Select activation script discovery method:${COLOR_RESET}"
  echo "1) Specify path to activation script"
  echo "2) Auto-discover script location"
  
  while true; do
    read -rp "Your choice (1-2): " script_discovery_choice
    case "$script_discovery_choice" in
      1) 
        locate_script_manual
        break ;;
      2)
        locate_script_auto
        break ;;
      *)
        log "ERROR" "Invalid choice. Please enter 1-2."
        ;;
    esac
  done
}

locate_script_manual() {
  while true; do
    read -rp "Enter path to ActivateProtocol.s.sol: " ACTIVATION_SCRIPT
    if [[ -f "$ACTIVATION_SCRIPT" ]]; then
      break
    else
      log "ERROR" "File not found: $ACTIVATION_SCRIPT"
    fi
  done
  
  # Default contract name
  ACTIVATION_CONTRACT="ActivateProtocol"
  read -rp "Enter contract name [press Enter for default: ActivateProtocol]: " user_contract
  if [[ -n "$user_contract" ]]; then
    ACTIVATION_CONTRACT="$user_contract"
  fi
}

locate_script_auto() {
  log "INFO" "Searching for activation script..."
  
  # Find all potential activation scripts
  local script_files=($(find "$ROOT_DIR" -name "ActivateProtocol.s.sol"))
  
  if [[ ${#script_files[@]} -eq 0 ]]; then
    log "ERROR" "No activation script found. Please specify path manually."
    locate_script_manual
    return
  fi
  
  if [[ ${#script_files[@]} -eq 1 ]]; then
    ACTIVATION_SCRIPT="${script_files[0]}"
    log "SUCCESS" "Found activation script: $ACTIVATION_SCRIPT"
  else
    echo -e "\n${COLOR_YELLOW}Multiple activation scripts found. Please select:${COLOR_RESET}"
    for i in "${!script_files[@]}"; do
      echo "$((i+1))) ${script_files[$i]}"
    done
    
    while true; do
      read -rp "Select script (1-${#script_files[@]}): " script_choice
      if [[ "$script_choice" =~ ^[0-9]+$ && "$script_choice" -ge 1 && "$script_choice" -le "${#script_files[@]}" ]]; then
        ACTIVATION_SCRIPT="${script_files[$((script_choice-1))]}"
        break
      else
        log "ERROR" "Invalid selection. Please enter a number between 1 and ${#script_files[@]}."
      fi
    done
  fi
  
  # Default contract name
  ACTIVATION_CONTRACT="ActivateProtocol"
  read -rp "Enter contract name [press Enter for default: ActivateProtocol]: " user_contract
  if [[ -n "$user_contract" ]]; then
    ACTIVATION_CONTRACT="$user_contract"
  fi
}

configure_network() {
  echo -e "\n${COLOR_YELLOW}Network Configuration${COLOR_RESET}"
  
  # RPC URL (required)
  while true; do
    read -rp "Enter RPC URL for the target network: " RPC_URL
    if [[ -n "$RPC_URL" ]]; then
      echo "RPC_URL=$RPC_URL" >> "$TMP_ENV_FILE"
      break
    else
      log "ERROR" "RPC URL is required for protocol activation."
    fi
  done
  
  # Network ID/Chain ID
  read -rp "Enter chain ID (e.g., 1 for Mainnet, 11155111 for Sepolia) [default: 1]: " CHAIN_ID
  CHAIN_ID=${CHAIN_ID:-1}
  echo "CHAIN_ID=$CHAIN_ID" >> "$TMP_ENV_FILE"
  
  # Network warning
  if [[ "$CHAIN_ID" == "1" ]]; then
    echo -e "${COLOR_RED}⚠️  WARNING: You are about to activate on MAINNET!${COLOR_RESET}"
    prompt_for_confirmation "CONFIRM-MAINNET" "Type 'CONFIRM-MAINNET' to proceed on Ethereum Mainnet"
  fi
}

# Select keystore for transaction
select_keystore() {
  echo -e "\n${COLOR_YELLOW}Available keystores:${COLOR_RESET}"
  cast wallet list
  
  while true; do
    read -rp "Enter keystore name for activation: " KEYSTORE_NAME
    if [[ -f "$HOME/.foundry/keystores/$KEYSTORE_NAME" ]]; then
      break
    else
      log "ERROR" "Keystore '$KEYSTORE_NAME' not found."
    fi
  done
}

# 🚀 Main function to start the script
main() {
  echo -e "\n${COLOR_GREEN}🚀 Protocol Activation Workflow${COLOR_RESET}"
  echo ""
  echo -e "${COLOR_YELLOW}This script will guide you through activating the DLMP protocol.${COLOR_RESET}\n"
  echo -e "${COLOR_RED}⚠️  IMPORTANT: Protocol activation is a one-time operation!${COLOR_RESET}"
  echo -e "${COLOR_RED}⚠️  Once activated, the protocol cannot be activated again.${COLOR_RESET}\n"
  
  validate_env
  discover_contracts
  configure_network
  collect_activation_parameters
  validate_activation_requirements
  execute_activation
}

# Start the script
main "$@"
