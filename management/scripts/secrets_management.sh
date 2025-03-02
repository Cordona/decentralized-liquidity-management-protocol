#!/usr/bin/env bash

set -euo pipefail  # Strict error handling

KEYSTORE_DIR="$HOME/.foundry/keystores"

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

create_keystore() {
  log "INFO" "Creating a new keystore..."
  read -rp "Enter keystore name: " KEYSTORE_NAME

  if [[ -f "$KEYSTORE_DIR/$KEYSTORE_NAME" ]]; then
    log "ERROR" "Keystore '$KEYSTORE_NAME' already exists!"
    exit 1
  fi

  log "INFO" "Importing private key to create keystore..."
  cast wallet import "$KEYSTORE_NAME" --interactive
  log "SUCCESS" "Keystore '$KEYSTORE_NAME' successfully created!"
}

remove_keystore() {
  log "WARN" "⚠️  Keystore Removal - Proceed with caution!"

  if [[ -z $(cast wallet list) ]]; then
    log "WARN" "No keystores found in $KEYSTORE_DIR"
    log "INFO" "💡 Tip: Use 'Create Keystore' to generate one."
    exit 0
  fi

  cast wallet list
  echo ""
  read -rp "Enter keystore name to remove: " KEYSTORE_NAME

  if [[ ! -f "$KEYSTORE_DIR/$KEYSTORE_NAME" ]]; then
    log "ERROR" "Keystore '$KEYSTORE_NAME' not found!"
    exit 1
  fi

  log "ERROR" "⚠️  This action is irreversible!"
  read -rp "Type 'DELETE' to confirm removal of '$KEYSTORE_NAME': " CONFIRM
  if [[ "$CONFIRM" == "DELETE" ]]; then
    rm -f "$KEYSTORE_DIR/$KEYSTORE_NAME"
    log "SUCCESS" "Keystore '$KEYSTORE_NAME' successfully removed!"
  else
    log "WARN" "Deletion cancelled."
  fi
}

list_keystores() {
  log "INFO" "Listing all keystores..."
  cast wallet list || log "WARN" "No keystores found in $KEYSTORE_DIR"
}

reveal_keystore_address() {
  log "INFO" "📋 Key Address Reveal"

  if [[ -z $(cast wallet list) ]]; then
    log "WARN" "No keystores found in $KEYSTORE_DIR"
    log "INFO" "💡 Tip: Use 'Create Keystore' to generate one."
    exit 0
  fi

  cast wallet list
  echo ""
  read -rp "Enter keystore name to reveal address: " KEYSTORE_NAME

  if [[ ! -f "$KEYSTORE_DIR/$KEYSTORE_NAME" ]]; then
    log "ERROR" "Keystore '$KEYSTORE_NAME' not found!"
    exit 1
  fi

  log "INFO" "Retrieving address..."
  ADDRESS=$(cast wallet address --keystore "$KEYSTORE_DIR/$KEYSTORE_NAME")
  log "SUCCESS" "Address for '$KEYSTORE_NAME': $ADDRESS"
}

main_menu() {
  echo -e "\n${COLOR_YELLOW}Key Management Menu:${COLOR_RESET}"
  echo "1) Create a new keystore"
  echo "2) Remove an existing keystore"
  echo "3) List all keystores"
  echo "4) Reveal a keystore address"
  echo "5) Exit"

  while true; do
    read -rp "Enter your choice (1-5): " choice
    case "$choice" in
      1) create_keystore; break ;;
      2) remove_keystore; break ;;
      3) list_keystores; break ;;
      4) reveal_keystore_address; break ;;
      5) log "INFO" "Exiting..."; exit 0 ;;
      *) log "ERROR" "Invalid choice. Please enter a number between 1-5." ;;
    esac
  done
}

main_menu