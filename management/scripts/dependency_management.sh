#!/usr/bin/env bash

set -euo pipefail  # Strict error handling

# Color Codes
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_PURPLE="\033[35m"

# Configuration file for dependencies
DEPENDENCY_FILE="$(dirname "$0")/dependencies.conf"

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

# Initialize dependency file if it doesn't exist
initialize_dependency_file() {
  if [ ! -f "$DEPENDENCY_FILE" ]; then
    log "INFO" "Creating dependency configuration file..."
    cat > "$DEPENDENCY_FILE" << EOF
# DLMP Protocol Dependencies
# Last updated: $(date)
# Format: owner/repo@version (one per line)
foundry-rs/forge-std@v1.9.6
OpenZeppelin/openzeppelin-contracts@v5.1.0
Uniswap/v2-core@v1.0.1
Uniswap/v2-periphery@v1.0.0-beta.0
Uniswap/v3-core@v1.0.0
Uniswap/v3-periphery@v1.3.0
EOF
    log "SUCCESS" "Created dependency configuration file at $DEPENDENCY_FILE"
  fi
}

# Load dependencies from file
load_dependencies() {
  initialize_dependency_file
  DEPENDENCIES=()
  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    DEPENDENCIES+=("$line")
  done < "$DEPENDENCY_FILE"
  
  # Log count of dependencies loaded
  echo ""
  log "INFO" "Loaded ${#DEPENDENCIES[@]} dependencies from configuration"
}

# Add dependency to file
add_dependency() {
  local dep="$1"
  # Check if dependency already exists
  if grep -q "^$dep$" "$DEPENDENCY_FILE"; then
    log "INFO" "Dependency $dep already exists in configuration"
  else
    echo "$dep" >> "$DEPENDENCY_FILE"
    log "SUCCESS" "Added $dep to dependency configuration"
  fi
  # Reload dependencies
  load_dependencies
}

# Remove dependency from file
remove_dependency() {
  local dep="$1"
  # Create temp file without the dependency
  if grep -q "^$dep$" "$DEPENDENCY_FILE"; then
    grep -v "^$dep$" "$DEPENDENCY_FILE" > "${DEPENDENCY_FILE}.tmp"
    # Replace original file
    mv "${DEPENDENCY_FILE}.tmp" "$DEPENDENCY_FILE"
    log "SUCCESS" "Removed $dep from dependency configuration"
    # Reload dependencies
    load_dependencies
  else
    log "WARN" "Dependency $dep not found in configuration"
  fi
}

install_dependencies() {
  log "INFO" "🔍 Installing protocol dependencies..."

  # Make sure we have up-to-date dependencies list
  load_dependencies

  if [ ! -d "lib" ]; then
    mkdir -p lib
  fi

  local success=true

  for dep in "${DEPENDENCIES[@]}"; do
    log "INFO" "Installing $dep"
    if forge install --no-commit "$dep"; then
      log "SUCCESS" "✅ Installed $dep"
    else
      log "ERROR" "❌ Failed to install $dep"
      success=false
    fi
  done

  if [ "$success" = true ]; then
    log "SUCCESS" "🎉 All dependencies installed successfully!"

    # Ensure lib/ is removed from Git tracking
    log "INFO" "🔍 Ensuring lib/ is ignored by Git..."
    git rm -r --cached lib/ 2>/dev/null || log "INFO" "lib/ was not tracked by Git"

  else
    log "ERROR" "⚠️ Some dependencies failed to install. Check the logs above."
    exit 1
  fi
}

install_new_dependency() {
  echo ""
  printf "${COLOR_BLUE}Enter dependency to install (format: owner/repo@version):${COLOR_RESET} "
  read -r new_dep
  
  # Validate format
  if [[ ! "$new_dep" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+(@[a-zA-Z0-9\._-]+)?$ ]]; then
    log "ERROR" "Invalid format. Expected format: owner/repo@version"
    return
  fi
  
  # Install the dependency
  log "INFO" "Installing $new_dep..."
  if forge install --no-commit "$new_dep"; then
    # Add to dependency file
    add_dependency "$new_dep"
    log "SUCCESS" "✅ Installed $new_dep and updated dependencies!"

    # Ensure lib/ is removed from Git tracking
    log "INFO" "🔍 Ensuring lib/ is ignored by Git..."
    git rm -r --cached lib/ 2>/dev/null || log "INFO" "lib/ was not tracked by Git"

  else
    log "ERROR" "❌ Failed to install $new_dep"
  fi
}

list_dependencies() {
  # Make sure we have up-to-date dependencies list
  load_dependencies
  
  echo -e "\n${COLOR_YELLOW}Available dependencies${COLOR_RESET}"
  echo ""
  
  if [ ! -d "lib" ] || [ -z "$(ls -A lib 2>/dev/null)" ]; then
    log "WARN" "No dependencies found in the lib directory! Run 'install' first."
    
    echo -e "\n${COLOR_BLUE}Configured Dependencies (Not Installed Yet):${COLOR_RESET}"
    for dep in "${DEPENDENCIES[@]}"; do
      echo "- $dep"
    done
    
    return
  fi
  
  printf "%-30s %-20s\n" "DEPENDENCY" "VERSION"
  printf "%-30s %-20s\n" "----------" "-------"
  
  for dir in lib/*; do
    if [ -d "$dir" ]; then
      name=$(basename "$dir")
      
      # Try different approaches to get version info
      if [ -d "$dir/.git" ]; then
        # Get into the directory
        cd "$dir"
        
        # Try to get tag/version info (prioritize tags over branches)
        version=$(git describe --tags 2>/dev/null || git branch --show-current 2>/dev/null || echo "unknown")
        
        # If we just got "unknown", try to get the exact commit with repo info
        if [ "$version" = "unknown" ]; then
          remote_url=$(git remote get-url origin 2>/dev/null || echo "")
          if [ -n "$remote_url" ]; then
            commit=$(git rev-parse --short HEAD)
            version="commit:$commit"
          fi
        fi
        
        # Get back to parent
        cd - > /dev/null
      else
        version="unknown (not git managed)"
      fi
      
      printf "%-30s %-20s\n" "$name" "$version"
    fi
  done

  echo -e "\n${COLOR_GREEN}Tip: For the most accurate version info, check your dependency configuration${COLOR_RESET}"
}

export_dependency_list() {
  # Make sure we have up-to-date dependencies list
  load_dependencies
  
  log "INFO" "Exporting dependency list to dependencies.txt..."
  echo ""
  
  {
    echo "# DLMP Protocol Dependencies"
    echo "# Generated on $(date)"
    echo ""
    echo "## Configured Dependencies"
    
    for dep in "${DEPENDENCIES[@]}"; do
      echo "- $dep"
    done
    
    echo ""
    echo "## Detailed Installed Versions"
    
    if [ -d "lib" ]; then
      for dir in lib/*; do
        if [ -d "$dir" ]; then
          name=$(basename "$dir")
          if [ -d "$dir/.git" ]; then
            cd "$dir"
            version=$(git describe --tags 2>/dev/null || git rev-parse --short HEAD)
            cd - > /dev/null
            echo "- $name: $version"
          else
            echo "- $name: unknown (not git managed)"
          fi
        fi
      done
    else
      echo "No dependencies installed yet."
    fi
  } > dependencies.txt
  
  log "SUCCESS" "✅ Dependencies exported to dependencies.txt"
}

update_dependencies() {
  # Make sure we have up-to-date dependencies list
  load_dependencies
  
  log "INFO" "🔄 Updating dependencies to latest versions..."
  
  if [ ! -d "lib" ]; then
    log "WARN" "No dependencies found! Installing from scratch..."
    install_dependencies
    return
  fi
  
  if forge update; then
    log "SUCCESS" "🎉 All dependencies updated successfully!"
  else
    log "ERROR" "⚠️ Failed to update dependencies."
    exit 1
  fi
}

check_dependency_versions() {
  # Make sure we have up-to-date dependencies list
  load_dependencies
  
  log "INFO" "🔍 Checking for newer versions of dependencies..."
  
  if [ ! -d "lib" ]; then
    log "WARN" "No dependencies found! Run 'install' first."
    return
  fi
  
  local has_updates=false
  
  for dir in lib/*; do
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
      name=$(basename "$dir")
      cd "$dir"
      
      current=$(git describe --tags 2>/dev/null || git rev-parse --short HEAD)
      git fetch --quiet origin
      latest=$(git describe --tags $(git rev-list --tags --max-count=1 2>/dev/null) 2>/dev/null || echo "no tags")
      
      if [ "$latest" != "no tags" ] && [ "$current" != "$latest" ]; then
        log "INFO" "$name: $current → $latest (update available)"
        has_updates=true
      else
        log "INFO" "$name: $current (up to date)"
      fi
      
      cd - > /dev/null
    fi
  done
  
  if [ "$has_updates" = false ]; then
    log "SUCCESS" "✅ All dependencies are up to date!"
  else
    log "WARN" "⚠️ Updates available for some dependencies. Consider running 'update'."
  fi
}

clean_dependencies() {
  log "WARN" "⚠️  This will remove ALL dependencies from the 'lib' directory!"
  read -rp "Type 'CLEAN' to confirm: " confirm

  if [ "$confirm" = "CLEAN" ]; then
    log "INFO" "Removing all dependencies..."

    # Remove all dependencies from lib/
    rm -rf lib

    # Ensure lib/ is removed from Git tracking
    log "INFO" "🔍 Removing lib/ from Git tracking..."
    git rm -r --cached lib/ > /dev/null 2>&1 || log "INFO" "lib/ was not tracked by Git"

    # Ask the user if they want to remove .gitmodules
    if [ -f .gitmodules ]; then
      echo ""
      read -rp "Do you want to remove .gitmodules as well? (yes/[no]): " remove_gitmodules
      remove_gitmodules=${remove_gitmodules:-no}  # Default to 'no' if the user presses Enter

      if [[ "$remove_gitmodules" == "yes" ]]; then
        log "INFO" "🔍 Removing all submodules from .gitmodules..."
        git submodule deinit -f --all > /dev/null 2>&1
        rm -rf .git/modules/lib
        git rm -f .gitmodules > /dev/null 2>&1 || log "INFO" ".gitmodules already removed"
        log "SUCCESS" "✅ .gitmodules removed!"
      else
        log "INFO" "Keeping .gitmodules as per user request."
      fi
    fi

    log "SUCCESS" "✅ Dependencies removed! Run 'install' to reinstall them."
  else
    log "INFO" "Operation cancelled."
  fi
}

remove_specific_dependency() {
  # Make sure we have up-to-date dependencies list
  load_dependencies
  
  echo -e "\n${COLOR_YELLOW}Available dependencies:${COLOR_RESET}"

  if [ ! -d "lib" ] || [ -z "$(ls -A lib 2>/dev/null)" ]; then
    log "WARN" "No dependencies found to remove!"
    return
  fi
  
  # List dependencies with numbers
  local i=1
  declare -a deps_array
  declare -a config_array
  
  for dir in lib/*; do
    if [ -d "$dir" ]; then
      name=$(basename "$dir")
      echo "$i) $name"
      deps_array[$i]="$name"
      
      # Find the matching config entry
      for dep in "${DEPENDENCIES[@]}"; do
        if [[ "$dep" == *"$name"* ]]; then
          config_array[$i]="$dep"
          break
        fi
      done
      
      i=$((i+1))
    fi
  done
  
  # Prompt for selection
  read -rp "Enter the number of the dependency to remove (or 0 to cancel): " selection
  
  if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -gt 0 ] && [ "$selection" -lt "$i" ]; then
    dep_to_remove="${deps_array[$selection]}"
    config_to_remove="${config_array[$selection]:-$dep_to_remove}"
    
    log "WARN" "⚠️ You are about to remove: $dep_to_remove"
    read -rp "Type 'REMOVE' to confirm: " confirm
    
    if [ "$confirm" = "REMOVE" ]; then
      # Remove the directory
      rm -rf "lib/$dep_to_remove"
      
      # Remove from configuration
      if [ -n "$config_to_remove" ]; then
        remove_dependency "$config_to_remove"
      fi
      
      log "SUCCESS" "✅ Removed $dep_to_remove and updated dependency configuration!"
    else
      log "INFO" "Operation cancelled."
    fi
  else
    log "INFO" "Invalid selection or cancelled."
  fi
}

# Load dependencies at startup
load_dependencies

main_menu() {
  echo -e "\n${COLOR_YELLOW}Dependency Management Menu:${COLOR_RESET}"
  echo "1) Install all dependencies"
  echo "2) Add new dependency"
  echo "3) List dependencies (with versions)"
  echo "4) Export dependency list to file"
  echo "5) Update dependencies"
  echo "6) Check for newer versions"
  echo "7) Remove specific dependency"
  echo "8) Remove all dependencies"
  echo "9) Exit"

  while true; do
    read -rp "Enter your choice (1-9): " choice
    case "$choice" in
      1) install_dependencies; break ;;
      2) install_new_dependency; break ;;
      3) list_dependencies; break ;;
      4) export_dependency_list; break ;;
      5) update_dependencies; break ;;
      6) check_dependency_versions; break ;;
      7) remove_specific_dependency; break ;;
      8) clean_dependencies; break ;;
      9) log "INFO" "Exiting..."; exit 0 ;;
      *) log "ERROR" "Invalid choice. Please enter a number between 1-9." ;;
    esac
  done
}

# Handle direct command execution if provided as argument
if [ $# -gt 0 ]; then
  case "$1" in
    "install") install_dependencies ;;
    "list") list_dependencies ;;
    "export") export_dependency_list ;;
    "update") update_dependencies ;;
    "check") check_dependency_versions ;;
    "clean") clean_dependencies ;;
    *) log "ERROR" "Unknown command: $1"; exit 1 ;;
  esac
else
  # Show interactive menu if no arguments
  main_menu
fi