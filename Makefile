# Default environment file
TEST_ENV_FILE ?= .env/test.env
SEPOLIA_ENV_FILE ?= .env/sepolia.env
MAINNET_ENV_FILE ?= .env/mainnet.env

# =============================
# 🎨 Color Variables
# =============================
GREEN  := \033[32m
YELLOW := \033[33m
RED    := \033[31m
BLUE   := \033[34m
NC     := \033[0m  # No Color / Reset

.PHONY: help dependencies test coverage analyze format secrets deploy-protocol deploy-script activate

help:
	@echo ""
	@echo "$(GREEN) Protocol Development Toolkit$(NC)"
	@echo ""
	@echo "$(YELLOW)📦  Dependency Management:$(NC)"
	@echo "  make dependencies - Interactive dependency management system"
	@echo "    ├─ Install protocol dependencies with version pinning"
	@echo "    ├─ Add new dependencies to your project"
	@echo "    ├─ List installed dependencies with versions"
	@echo "    ├─ Update dependencies to latest compatible versions"
	@echo "    ├─ Check for newer versions without upgrading"
	@echo "    ├─ Selectively remove specific dependencies"
	@echo "    └─ Export dependency information to documentation"
	@echo ""
	@echo "$(YELLOW)🧪  Testing & Coverage:$(NC)"
	@echo "  make test         - Run tests with configurable logging"
	@echo "    ├─ Select verbosity level (silent, minimal, all logs)"
	@echo "    └─ Run specific test cases if needed"
	@echo "  make coverage     - Generate code coverage reports"
	@echo "    ├─ Supports basic, terminal, and file export modes"
	@echo "    └─ Provides detailed insights on contract execution"
	@echo ""
	@echo "$(YELLOW)🔍  Security & Code Analysis:$(NC)"
	@echo "  make analyze      - Run combined security analysis (Slither + Aderyn)"
	@echo "    ├─ Detects vulnerabilities in Solidity code"
	@echo "    ├─ Scans for security risks and generates report.md"
	@echo "    └─ Ensures contract security before deployment"
	@echo "  make format       - Format Solidity code using forge fmt"
	@echo ""
	@echo "$(YELLOW)🔑  Secrets Management:$(NC)"
	@echo "  make secrets      - Manage and store sensitive credentials securely"
	@echo "    ├─ Encrypt & store private keys"
	@echo "    ├─ Retrieve stored secrets when required"
	@echo "    └─ Keep keystore access secure"
	@echo ""
	@echo "$(YELLOW)🚀  Script Deployment:$(NC)"
	@echo "  make deploy-script - Guided deployment script execution"
	@echo "    ├─ Prompts for deployment script path"
	@echo "    ├─ Collects contract name and deployer address"
	@echo "    ├─ Validates keystore and RPC configuration"
	@echo "    ├─ Supports Etherscan verification"
	@echo "    ├─ Ensures correct contract deployment settings"
	@echo "    ├─ Provides a final confirmation step"
	@echo "    └─ Executes deployment via Foundry (forge script)"
	@echo ""
	@echo "$(YELLOW)🚀  Protocol Deployment:$(NC)"
	@echo "  make deploy-protocol - Interactive deployment workflow"
	@echo "    ├─ Supports both Sepolia and Mainnet"
	@echo "    ├─ Includes contract verification"
	@echo "    └─ Loads network-specific configurations"
	@echo ""
	@echo "$(YELLOW)⚡  Protocol Activation:$(NC)"
	@echo "  make activate-protocol     - Execute the activation workflow for deployed contracts"
	@echo "    ├─ Discovers deployed contract addresses"
	@echo "    ├─ Collects required activation parameters"
	@echo "    ├─ Ensures necessary approvals and balance checks"
	@echo "    ├─ Supports interactive and automated execution modes"
	@echo "    ├─ Validates protocol readiness before activation"
	@echo "    ├─ Runs network-specific activation on Sepolia or Mainnet"
	@echo "    ├─ Provides execution logs and confirmation prompts"
	@echo "    └─ Ensures activation cannot be re-executed post-success"
	@echo ""
	@echo "$(GREEN)💡  Development Tips:$(NC)"
	@echo "  1. Always run 'make dependencies' after cloning the repo"
	@echo "  2. Ensure environment files are configured:"
	@echo "     ├─ .env/test.env for local fork testing at mainnet"
	@echo "     ├─ .env/sepolia.env for testnet"
	@echo "     └─ .env/mainnet.env for mainnet"
	@echo "  3. Run tests before making significant changes"
	@echo "  4. Check for dependency updates periodically"
	@echo ""
	@echo "$(GREEN)🛡️  Security Best Practices:$(NC)"
	@echo "  - Verify dependency versions match audited releases"
	@echo "  - Backup keystores regularly"
	@echo "  - Run complete security analysis before deployment"
	@echo "  - Monitor gas prices for optimal deployment timing"
	@echo ""

dependencies:
	./management/scripts/dependency_management.sh

test:
	./management/scripts/test.sh

coverage:
	./management/scripts/coverage.sh

analyze:
	./management/scripts/static_analysis.sh

format :; forge fmt

slither:
	 slither . \
	 --config-file slither.config.json \
	 --checklist --show-ignored-findings

aderyn:
	aderyn .

secrets:
	./management/scripts/secrets_management.sh

deploy-protocol:
	./management/scripts/deploy_protocol.sh

deploy-script:
	./management/scripts/simple_deployment.sh

activate-protocol:
	./management/scripts/activate_protocol.sh