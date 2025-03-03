# Decentralized Liquidity Management Protocol (DLMP)

## **Table of Contents**  
- [Decentralized Liquidity Management Protocol (DLMP)](#decentralized-liquidity-management-protocol-dlmp)
  - [**Table of Contents**](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [Protocol Overview](#protocol-overview)
    - [Problem Statement](#problem-statement)
    - [Key Benefits](#key-benefits)
  - [2. Core Components](#2-core-components)
    - [Protocol Token Integration](#protocol-token-integration)
    - [Liquidity Management System](#liquidity-management-system)
    - [Component Architecture](#component-architecture)
  - [3. Key Features \& Capabilities](#3-key-features--capabilities)
    - [Unified Liquidity Deployment](#unified-liquidity-deployment)
    - [Secure Liquidity Locking](#secure-liquidity-locking)
    - [Multi-DEX Version Support](#multi-dex-version-support)
    - [Emergency Token Recovery System](#emergency-token-recovery-system)
  - [4. Security Architecture](#4-security-architecture)
    - [Role Management System](#role-management-system)
    - [Key Actors and Responsibilities](#key-actors-and-responsibilities)
      - [1. Deployer (Protocol Creator)](#1-deployer-protocol-creator)
      - [2. Protocol Manager](#2-protocol-manager)
      - [3. Protocol Activator](#3-protocol-activator)
      - [4. Factory Components](#4-factory-components)
      - [5. Liquidity Locker](#5-liquidity-locker)
    - [Security Design Principles](#security-design-principles)
      - [1. Privilege Separation](#1-privilege-separation)
      - [2. Authority Delegation Chain](#2-authority-delegation-chain)
      - [3. Single Entry Point + Orchestration Layer](#3-single-entry-point--orchestration-layer)
      - [4. Defense in Depth](#4-defense-in-depth)
      - [5. Recovery Mechanisms](#5-recovery-mechanisms)
    - [Permission Models \& State](#permission-models--state)
    - [Security Benefits \& Considerations](#security-benefits--considerations)
- [5. Getting Started](#5-getting-started)
  - [5.1 Development Environment Setup](#51-development-environment-setup)
    - [A. Requirements](#a-requirements)
      - [Core Dependencies](#core-dependencies)
      - [Recommended Tools](#recommended-tools)
    - [B. Project Setup](#b-project-setup)
    - [C. Repository Structure](#c-repository-structure)
      - [Core Protocol Components](#core-protocol-components)
      - [Foundation Components](#foundation-components)
      - [Component Relationships](#component-relationships)
      - [Interface Pattern](#interface-pattern)
    - [D. Environment Configuration](#d-environment-configuration)
      - [Environment Files Organization](#environment-files-organization)
      - [Local Development Configuration (test.env)](#local-development-configuration-testenv)
      - [Setting Up Your Environment](#setting-up-your-environment)
      - [Referencing Environment Files](#referencing-environment-files)
      - [Advanced Configuration](#advanced-configuration)
  - [5.2 Development Workflow](#52-development-workflow)
    - [A. Using the Makefile](#a-using-the-makefile)
      - [The Protocol Command Center](#the-protocol-command-center)
      - [Interactive Workflow Design](#interactive-workflow-design)
    - [B. Running Tests](#b-running-tests)
      - [Interactive Testing Workflow](#interactive-testing-workflow)
      - [Running Specific Tests](#running-specific-tests)
    - [C. Code Coverage \& Analysis](#c-code-coverage--analysis)
      - [Coverage Analysis](#coverage-analysis)
    - [D. Security Analysis](#d-security-analysis)
      - [Static Analysis](#static-analysis)
      - [Code Formatting](#code-formatting)
    - [E. Workflow Best Practices](#e-workflow-best-practices)
- [6. Deployment Guide](#6-deployment-guide)
  - [6.1 Pre-deployment Preparation](#61-pre-deployment-preparation)
    - [A. Network-Specific Configuration](#a-network-specific-configuration)
    - [B. Secrets Management](#b-secrets-management)
  - [6.2 Deployment Workflow](#62-deployment-workflow)
    - [A. The Deployment Pipeline](#a-the-deployment-pipeline)
    - [B. Pre-Deployment Validation](#b-pre-deployment-validation)
      - [Coverage Requirements](#coverage-requirements)
    - [C. Security Analysis](#c-security-analysis)
      - [Handling Security Findings](#handling-security-findings)
    - [D. Network Selection and Deployment](#d-network-selection-and-deployment)
      - [Protocol Architecture Review](#protocol-architecture-review)
      - [Final Deployment Steps](#final-deployment-steps)
  - [6.3 Post-Deployment Operations](#63-post-deployment-operations)
    - [A. Deployment Verification](#a-deployment-verification)
    - [B. Protocol Activation](#b-protocol-activation)
    - [C. Security Best Practices](#c-security-best-practices)


## 1. Introduction

### Protocol Overview

DLMP is an advanced protocol designed to streamline and secure the token launch process on Uniswap (V2 and V3), helping token creators establish strong liquidity foundations with robust security guarantees. By automating critical liquidity operations and implementing industry-standard security practices, the protocol eliminates common pain points and vulnerabilities in the token launch lifecycle.

### Problem Statement

Token launches face several critical challenges that our protocol directly addresses:

1. **Fragmented Liquidity Management** - Creating and managing liquidity pools across Uniswap V2/V3 typically requires manual, error-prone processes and deep technical knowledge

2. **Trust & Security Concerns** - Token launches without proper liquidity locking mechanisms create significant trust issues and enable potential rug pulls

3. **Complex Integration Requirements** - Developers must navigate multiple interfaces, fee structures, and technical specifications across different Uniswap versions

4. **Technical Barriers to Entry** - Many promising projects lack the technical expertise to implement secure liquidity strategies

5. **Operational Overhead** - Managing liquidity across multiple pools, tracking positions, and handling token supply requires significant ongoing effort

### Key Benefits

- **Simplified Token Launch Process** - Automate the entire journey from token creation to trading availability
- **Enhanced Security** - Implement industry best practices with role-based access control and defense-in-depth
- **Reduced Technical Overhead** - Eliminate complex manual integration with Uniswap ecosystems
- **Stronger Market Trust** - Provide verifiable liquidity locking and transparent operations
- **Operational Efficiency** - Manage all aspects of your token's liquidity through a unified interface

## 2. Core Components

### Protocol Token Integration

DLMP not only manages liquidity but also integrates directly with your own ERC20 token. The protocol is designed to:

- **Deploy Your Protocol Token** - Create and configure your custom ERC20 token with your desired tokenomics
- **Establish Initial Liquidity** - Automatically pair your protocol token with other assets (ETH/WETH and custom pair tokens)
- **Manage Token Supply** - Handle remaining token supply distribution through configurable recipient mechanisms
- **Create Market Accessibility** - Make your token instantly tradable through automated pool creation

This streamlined approach eliminates the complex, error-prone process of manual token deployment and liquidity establishment, allowing projects to focus on building their core product rather than managing token logistics.

### Liquidity Management System

The protocol implements a comprehensive liquidity management workflow:

```
Token Launch → Pool Creation → Liquidity Provisioning → Liquidity Locking → Position Monitoring
```

This system handles the complete lifecycle of liquidity operations, from initial pool creation to ongoing position management, ensuring your token maintains healthy trading liquidity with minimal manual intervention.

### Component Architecture

DLMP follows a layered architecture with clear separation of concerns:

```
🔹 Protocol Manager (Gateway)
   │  Entry point for protocol operations
   ▼
🔸 Protocol Activator (Orchestrator)
   │  Coordination layer for complex processes
   ▼
🟢 Component Layer (Executors)
   │  Implementation units that perform actions
```

Each layer serves a distinct purpose:

- **Protocol Manager**: Entry point for all protocol operations, controlling access and orchestrating high-level workflows
- **Protocol Activator**: Coordinates multi-step processes, handling validation and orchestration across components
- **Component Layer**: Specialized execution modules including:
  - V2 Pool Factory: Creates and manages Uniswap V2 pools
  - V3 Pool Factory: Creates and manages Uniswap V3 positions
  - Liquidity Locker: Handles secure liquidity locking via UNCX

## 3. Key Features & Capabilities

### Unified Liquidity Deployment

- **Single-Transaction Activation** - Deploy liquidity across Uniswap V2 and V3 pools simultaneously
- **Configurable Fee Tiers** - Select appropriate fee tiers for V3 concentrated liquidity positions
- **Automated ETH/WETH Handling** - Seamlessly manage ETH/WETH conversions for pool creation

### Secure Liquidity Locking

- **UNCX Network Integration** - Direct connection with industry-standard locking service
- **Customizable Lock Duration** - Set lock periods of 365+ days to build investor confidence
- **Transparent Verification** - Easily verify lock status and conditions on-chain

### Multi-DEX Version Support

- **Uniswap V2 Integration** - Create and manage traditional liquidity pools
- **Uniswap V3 Support** - Deploy and manage concentrated liquidity positions
- **Full-Range Position Management** - Create optimal liquidity ranges for your token

### Emergency Token Recovery System

- **Isolated Recovery Role** - The TOKEN_RESCUER_ROLE is separate from operational administrative roles, enforcing separation of concerns
- **Stuck Token Protection** - Enables rescue of any ERC20-compatible tokens that might become trapped in protocol contracts
- **Transparent Recovery Process** - All recovery operations emit detailed events for full auditability
- **Secure Role Transition** - Includes capability to securely transfer rescue privileges to a new address if needed

This system serves as a critical safety net, allowing recovery from unexpected edge cases without compromising the protocol's core security model. By operating outside the normal protocol flow and requiring special privileges, the recovery system maintains strong security guarantees while providing essential protection against potential asset loss.

## 4. Security Architecture

### Role Management System

Our protocol implements a hierarchical role management system that creates clear boundaries of responsibility:

```
Deployer
   ├── Holds → TOKEN_RESCUER_ROLE   // Emergency Recovery
   ├── Initially has ADMIN_ROLE
   │   └── Transferred to → ProtocolManager
   │
   └── ProtocolManager
       ├── Becomes ADMIN for → ProtocolActivator
       │
       └── ProtocolActivator
           ├── Becomes ADMIN for → V2 Factory
           ├── Becomes ADMIN for → V3 Factory
           └── Becomes ADMIN for → Liquidity Locker
```

This architecture creates a deliberate separation between **external administration** and **internal execution**, following the principle of least privilege throughout the system.

### Key Actors and Responsibilities

#### 1. Deployer (Protocol Creator)
The deployer initializes the protocol and sets up the security architecture:
* Initiates deployment of all protocol contracts
* Initially holds all administrative privileges 
* Strategically delegates permissions during initialization
* **Retains emergency recovery capabilities** via TOKEN_RESCUER_ROLE
* After deployment, becomes the **external admin** with limited, focused access

#### 2. Protocol Manager
Acts as the primary gateway and command center for the entire protocol:
* Functions as the single entry point for protocol operations
* Receives administrative control from the deployer
* Controls protocol activation through the ProtocolActivator
* Manages token supply remainder functionality
* Provides view functions for liquidity tracking across V2/V3

#### 3. Protocol Activator
Serves as the orchestration layer between administration and execution:
* Functions as the execution engine for protocol setup
* Orchestrates complex multi-step activation processes
* Handles secure validation of configuration parameters
* Manages pool creation and liquidity locking workflows
* Controls factory and locker components as the internal admin

#### 4. Factory Components
Specialized modules that handle specific protocol tasks:
* **V2PoolFactory**: Creates and manages Uniswap V2 pools
* **V3PoolFactory**: Creates and manages Uniswap V3 concentrated liquidity positions
* Only respond to commands from ProtocolActivator (strict access control)

#### 5. Liquidity Locker
Secures protocol liquidity through integration with external services:
* Manages secure V2 liquidity locking (integrated with UNCX)
* Handles locking fees and ownership transitions
* Only responds to commands from ProtocolActivator

### Security Design Principles

Our role management architecture implements several critical security patterns:

#### 1. Privilege Separation
The external/internal admin distinction creates clear boundaries of responsibility that limit the blast radius of any potential compromise. By separating the ability to initiate protocol operations (external admin) from the execution of those operations (internal admin chain), we significantly reduce attack vectors.

#### 2. Authority Delegation Chain
The one-way flow of permissions (Deployer → Manager → Activator → Factories/Locker) establishes a unidirectional privilege model that prevents privilege escalation attacks. Each component only responds to its designated admin, creating a clean chain of responsibility.

#### 3. Single Entry Point + Orchestration Layer
Having the Protocol Manager as the gateway and the Activator as the orchestration layer creates a clean separation between authorization and execution concerns. This makes the system more auditable and easier to reason about.

#### 4. Defense in Depth
An attacker would need to compromise multiple components to gain significant control over the protocol. The layered security approach ensures that a breach at one level doesn't compromise the entire system.

#### 5. Recovery Mechanisms
The TOKEN_RESCUER_ROLE provides a safety net without compromising the main permission structure, allowing for emergency intervention if tokens need to be rescued from component contracts.

### Permission Models & State

After deployment, the protocol establishes the following permission state:

1. **Deployer**:
   - Retains TOKEN_RESCUER_ROLE for emergency recovery
   - Has ADMIN_ROLE only for the Protocol Manager
   - Cannot directly access factories or locker components

2. **Protocol Manager**:
   - Becomes the only entry point for protocol activation
   - Has exclusive ADMIN_ROLE for the Protocol Activator
   - Cannot directly operate factories or locker

3. **Protocol Activator**:
   - Has ADMIN_ROLE for V2Factory, V3Factory, and LiquidityLocker
   - Only responds to Protocol Manager commands
   - Orchestrates complex operations across multiple components

4. **Factory & Locker Components**:
   - Only respond to Protocol Activator commands
   - Cannot interact with other components independently
   - Provide emergency token recovery via TOKEN_RESCUER_ROLE

### Security Benefits & Considerations

This architecture offers several key benefits:

1. **Enhanced Auditability**: The clean separation makes it easier to reason about permissions and track actions through the system.

2. **Composition over Inheritance**: Components interact through well-defined interfaces rather than complex inheritance chains, reducing complexity and potential vulnerabilities.

3. **Minimal Attack Surface**: Each contract only exposes the minimum necessary functionality, reducing potential attack vectors.

4. **Recovery Readiness**: Emergency recovery mechanisms provide a safety net without compromising the security model.

By implementing this role management architecture, our protocol achieves a high standard of security while maintaining operational flexibility. The design draws inspiration from established security patterns in the industry while implementing a uniquely robust hierarchy that's tailored to our protocol's needs.

# 5. Getting Started

> This section will help you set up your development environment, understand the repository structure, and configure your workspace for DLMP development.

## 5.1 Development Environment Setup

### A. Requirements
-------------------

Setting up your development environment for DLMP requires a few key tools. Let's make sure you have everything you need to start building with confidence!

#### Core Dependencies

- **Git** - Version control system
  - Required for cloning the repository and managing your code changes
  - Installation: [git-scm.com](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - Verification: Run `git --version` in your terminal
  - Expected output: `git version x.x.x`

- **Foundry** - Ethereum development toolchain
  - Required for compiling, testing, and deploying smart contracts
  - Installation: [foundry.paradigm.xyz](https://getfoundry.sh/)
  - Verification: Run `forge --version` in your terminal
  - Expected output: `forge 0.2.0 (or newer)`
  - Tip: Run `foundryup` periodically to keep your toolchain updated

- **Make** - Build automation tool
  - Required for running the development workflows defined in our Makefile
  - Installation:
    - **macOS**: Included with Xcode Command Line Tools (`xcode-select --install`)
    - **Linux**: Available via package managers (`apt-get install make`, `yum install make`)
    - **Windows**: Available via [Chocolatey](https://chocolatey.org/) (`choco install make`) or WSL
  - Verification: Run `make --version` in your terminal
  - Expected output: `GNU Make x.x (or similar)`

#### Recommended Tools

- **Code Editor** with Solidity support
  - Visual Studio Code with [Solidity extension](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity)
  - Vim/Neovim with appropriate plugins
  - Any editor that provides syntax highlighting for Solidity

- **Terminal Environment**
  - Comfortable terminal environment for running commands
  - Familiarity with basic shell commands
  - For Windows users: Consider using WSL (Windows Subsystem for Linux) for a more consistent experience

### B. Project Setup
-------------------

Follow these steps to set up your development environment for DLMP:

1. **Clone the repository**
   ```bash
   git clone https://github.com/Cordona/decentralized-liquidity-management-protocol.git
   cd decentralized-liquidity-management-protocol
   ```

2. **Initialize Foundry project** (if not already initialized)
   ```bash
   # This creates the basic Foundry project structure
   forge init --force
   ```

3. **Install project dependencies**
   ```bash
   # This will launch our interactive dependency management tool
   make dependencies
   
   # Select option 1 to install all required dependencies
   ```

4. **Set up environment files**
   ```bash
   # Create the environment directory
   mkdir -p .env
   
   # Create test.env with the provided template in section 5.1.D
   nano .env/test.env
   ```

5. **Verify your setup**
   ```bash
   # Should display the help menu
   make help
   
   # Should compile the project without errors
   forge build
   ```

If all these commands run without errors, congratulations! 🎉 Your development environment is ready for building with DLMP.

### C. Repository Structure
-------------------

Let's break down how our codebase is organized. Understanding the project structure is key to efficient development and makes it easier to contribute to the protocol. 🏗️

```
src/                            # Core protocol source code
├── activator/                  # Protocol activation orchestration
├── common/                     # Shared utilities and core components
├── factories/                  # Pool factory implementations (V2/V3)
├── initializer/                # Module initialization system
├── locker/                     # Liquidity locking mechanism
├── manager/                    # Protocol gateway and management
├── rescuer/                    # Emergency recovery system
└── token/                      # Protocol token implementation
```

#### Core Protocol Components

- **`manager/`** - This is your entry point to the protocol! Contains `ProtocolManager.sol` which serves as the gateway for all external operations. If you're integrating with the protocol, start here. 🚪

- **`activator/`** - Contains `ProtocolActivator.sol` which orchestrates complex multi-step operations across different components. Think of this as the conductor of our protocol symphony. 🎮

- **`factories/`** - Houses our Uniswap integration components:
  - `v2/` - Implements the Uniswap V2 pool creation and management
  - `v3/` - Handles Uniswap V3 concentrated liquidity positions
  
- **`locker/`** - Contains `LiquidityLocker.sol` which handles our UNCX integration for secure liquidity locking. A critical component for establishing trust in the protocol. 🔒

#### Foundation Components

- **`common/`** - The backbone of our protocol with shared utilities:
  - `AdminInitializer.sol` - Manages admin role transitions and initialization
  - `BaseProtocol.sol` - Core validation and common error definitions
  - `RoleBased.sol` - Enhanced role management extending OpenZeppelin's AccessControl
  - `Roles.sol` - Security role definitions (ADMIN_ROLE, TOKEN_RESCUER_ROLE)
  - `Types.sol` - Shared data structures for protocol configuration
  - `Utils.sol` - Helper functions for token operations and address manipulations
  - `V3Constants.sol` - Uniswap V3-specific constants for pool creation

- **`initializer/`** - Contains the module initialization system that establishes secure role transitions between components.

- **`rescuer/`** - Implements our emergency recovery system for handling unexpected situations. A crucial safety net for the protocol. 🛟

- **`token/`** - Contains the implementation of our ERC20 token standard and WETH interface. The foundation of our liquidity operations.

#### Component Relationships

Our architecture follows a layered approach with clear boundaries:

1. **External interface** (`manager/`) - Where external calls enter the system
2. **Orchestration layer** (`activator/`) - Coordinates operations
3. **Execution components** (`factories/`, `locker/`) - Perform specific tasks

This separation creates a secure, maintainable codebase where components have clearly defined responsibilities and permissions. 💡

#### Interface Pattern

Notice how most modules follow an interface/implementation pattern (e.g., `IProtocolManager.sol`/`ProtocolManager.sol`). This pattern:

- Enables clear API definitions
- Supports potential upgradability
- Enforces separation of concerns
- Makes the code more testable

When working with the codebase, understanding these relationships will help you navigate and modify the protocol more effectively. 🚀

### D. Environment Configuration
-------------------

DLMP uses environment files to configure various aspects of development, testing, and deployment. This approach eliminates hardcoded values and makes the protocol adaptable to different networks and usage scenarios.

#### Environment Files Organization

We organize our configuration into separate environment files for different contexts:

```
.env/
├── test.env      # Local development and testing
├── sepolia.env   # Sepolia testnet deployment
└── mainnet.env   # Production deployment
```

#### Local Development Configuration (test.env)

For local testing, code coverage analysis, and static analysis, use the following configuration:

```
TOKEN_NAME="Test DFDX"
TOKEN_SYMBOL="TDFDX"
TOKEN_TOTAL_SUPPLY=888888888
PROTOCOL_TOKEN_LIQUIDITY=22000000
PAIR_TOKEN_LIQUIDITY=100000000
FEE=10000
DEADLINE=500
WETH_LIQUIDITY=10
ADMIN=0xFa377a04AFc78d158bCD59E9eFeDa07b3d89c7A3
SUPPLY_REMAINDER_RECIPIENT=0x9437f4c817C89571706BFe258957bf4B0ca9d6b7
LIQUIDITY_RECIPIENT=0x1a33f3e602D37AfFc69Da91C1bcA94941a1d498e
UNISWAP_V2_ROUTER_ADDR=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
UNISWAP_V2_FACTORY_ADDR=0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
UNISWAP_V3_POSITION_MANAGER_ADDR=0xC36442b4a4522E871399CD717aBDD847Ab11FE88
UNISWAP_V2_LIQUIDITY_LOCKER=0x59d7D55DdC58494FbBbca29904f108ece82Ac7FB
RPC_URL="YOUR_MAINNET_RPC_URL_HERE"
WETH_ADDR=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
LOCK_DURATION_DAYS=365
```

> 💡 **Important Note**: You must replace `YOUR_MAINNET_RPC_URL_HERE` with your own Ethereum mainnet RPC URL (from providers like Alchemy, Infura, or your own node). Our test suite runs against a mainnet fork to ensure realistic testing conditions.

The contract addresses provided above (UNISWAP_V2_ROUTER_ADDR, UNISWAP_V2_FACTORY_ADDR, etc.) are actual mainnet deployed contracts. **You should not change these values** for local testing since our fork-based tests expect to interact with these specific contracts.

#### Setting Up Your Environment

To configure your environment:

1. Create the environment directory:
```bash
mkdir -p .env
```

2. Create test.env with the provided template:
```bash
# Copy the template above into this file
nano .env/test.env
```

3. Verify your configuration loads correctly:
```bash
# This should display the help menu using your test.env configuration
make help
```

#### Referencing Environment Files

Our Makefile is designed to use these environment files automatically:

```bash
# For testing with the default test.env
make test

# For specifying a custom environment file
TEST_ENV_FILE=.env/custom.env make test

# For deploying to Sepolia
make deploy
# (This will prompt you to select the environment during execution)
```

#### Advanced Configuration

For production deployments or custom scenarios, you may need to adjust more parameters. The full set of supported configuration options is documented in `DeploymentVariables.sol` and `DeploymentTypes.s.sol`. These files define the complete contract initialization parameters and can serve as a reference for advanced configuration needs.

## 5.2 Development Workflow

### A. Using the Makefile
-------------------

DLMP uses a comprehensive Makefile system to streamline all development operations. This approach ensures consistent execution environments and simplifies complex workflows into intuitive commands.

#### The Protocol Command Center

The Makefile is your command center for all interactions with the protocol. Let's start by exploring the available commands:

```bash
make help
```

This will display the full toolkit available to you:

```
 Protocol Development Toolkit  

📦  Dependency Management:  
  make dependencies - Interactive dependency management system
    ├─ Install protocol dependencies with version pinning
    ├─ Add new dependencies to your project
    ├─ List installed dependencies with versions
    ├─ Update dependencies to latest compatible versions
    ├─ Check for newer versions without upgrading
    ├─ Selectively remove specific dependencies
    └─ Export dependency information to documentation

🚀  Deployment:  
  make deploy       - Interactive deployment workflow
    ├─ Supports both Sepolia and Mainnet
    ├─ Includes contract verification
    └─ Loads network-specific configurations

🧪  Testing & Coverage:  
  make test         - Run tests with configurable logging
    ├─ Select verbosity level (silent, minimal, all logs)
    └─ Run specific test cases if needed
  make coverage     - Generate code coverage reports
    ├─ Supports basic, terminal, and file export modes
    └─ Provides detailed insights on contract execution

🔍  Security & Code Analysis:  
  make analyze      - Run combined security analysis (Slither + Aderyn)
    ├─ Detects vulnerabilities in Solidity code
    ├─ Scans for security risks and generates report.md
    └─ Ensures contract security before deployment
  make format       - Format Solidity code using forge fmt

🔑  Secrets Management:  
  make secrets      - Manage and store sensitive credentials securely
    ├─ Encrypt & store private keys
    ├─ Retrieve stored secrets when required
    └─ Keep keystore access secure

💡  Development Tips:  
  1. Always run 'make dependencies' after cloning the repo
  2. Ensure environment files are configured:
     ├─ .env/sepolia.env for testnet
     └─ .env/mainnet.env for mainnet
  3. Run tests before making significant changes
  4. Check for dependency updates periodically

🛡️  Security Best Practices:  
  - Verify dependency versions match audited releases
  - Backup keystores regularly
  - Run complete security analysis before deployment
  - Monitor gas prices for optimal deployment timing
```

#### Interactive Workflow Design

What makes our development workflow special is its interactive nature. Rather than requiring complex command-line flags, the Makefile commands launch guided experiences that prompt you for the information needed at each step. This design dramatically reduces the learning curve and helps prevent common mistakes. 💡

### B. Running Tests
-------------------

Testing is at the core of our development process. All tests run on a mainnet fork to ensure realistic conditions and valid integrations with external contracts.

#### Interactive Testing Workflow

To run tests:

```bash
make test
```

This launches our interactive testing script:

```
./management/scripts/test.sh
[INFO] Loading environment variables...
Select logging level for forge test:
1) No logs (default)
2) Minimal logs (-vvv)
3) All logs (-vvvvv)
Enter your choice (1-3, default is 1): 
```

You can select different verbosity levels:
- **Level 1 (No logs)** - Clean output showing only test results
- **Level 2 (Minimal logs)** - Shows important events and state changes
- **Level 3 (All logs)** - Comprehensive debugging output

#### Running Specific Tests

The testing script also allows you to run specific test cases instead of the entire suite:

```
Would you like to run a specific test? (y/n): y
Enter the test function name (e.g. testActivateV2V3): testActivateV2
```

This targeted testing capability is invaluable when you're iterating on specific functionality. 🎯

### C. Code Coverage & Analysis
-------------------

Comprehensive code coverage analysis helps ensure the quality and security of the protocol implementation.

#### Coverage Analysis

To generate coverage reports:

```bash
make coverage
```

This launches our interactive coverage script:

```
./management/scripts/coverage.sh
[INFO] Loading environment variables...
Select coverage reporting mode:
1) Basic coverage - no detailed report (default)
2) Terminal report - select format
3) File export - detailed report to coverage_report.txt
Enter your choice (1-3, default is 1):
```

The three modes offer increasing levels of detail:
- **Basic coverage** - Quick summary statistics
- **Terminal report** - Formatted view with line-by-line details
- **File export** - Comprehensive report saved to a file for further analysis

### D. Security Analysis
-------------------

Our protocol employs industry-standard security analysis tools to detect potential vulnerabilities before they become problems.

#### Static Analysis

To run security analysis:

```bash
make analyze
```

This launches an interactive security analysis workflow:

```
./management/scripts/static_analysis.sh
Select Security Analysis Tool:
1) Slither - Static analysis for Solidity vulnerabilities
2) Aderyn - Smart contract security scanner
3) All - Run both Slither and Aderyn
Enter your choice (1-3): 
```

Each tool provides different insights:

- **Slither** - Comprehensive vulnerability detection focusing on:
  - Reentrancy risks
  - Access control issues
  - Gas optimization opportunities
  - Math precision concerns

- **Aderyn** - Smart contract security scanner that identifies:
  - Design pattern weaknesses
  - Potential economic attack vectors
  - Integration vulnerabilities

The combined analysis gives you a robust security perspective on your implementation. For production-ready code, always run both tools and address any findings. 🔐

#### Code Formatting

Maintaining consistent code style is important for readability and maintainability:

```bash
make format
```

This command uses Forge's formatter to standardize code styling across the codebase.

### E. Workflow Best Practices
-------------------

For optimal development efficiency, follow these proven workflow patterns:

1. **Start with proper configuration** - Ensure your .env files are correctly set up before running any commands

2. **Iterative development cycle**:
   ```
   make format → make test → make analyze → fix issues → repeat
   ```

3. **Progressive verbosity** - Start with no logs, and only increase verbosity when troubleshooting specific issues

4. **Targeted testing** - Use specific test functions during development to save time, but always run the full suite before deployment

5. **Security-first mindset** - Run `make analyze` regularly, not just at the end of development

6. **Complete workflow before deployment**:
   ```
   make test → make coverage → make analyze → make deploy
   ```

By following this structured approach, you'll develop more reliable, secure protocol implementations while saving time and avoiding common pitfalls. 🚀
...

# 6. Deployment Guide

This section covers the deployment process for the DLMP protocol, focusing on security, verification, and proper configuration.

## 6.1 Pre-deployment Preparation

### A. Network-Specific Configuration
-------------------

Each network requires specific configuration parameters. Below is the template for deploying to Sepolia testnet:

```
TOKEN_NAME="Test DFDX"
TOKEN_SYMBOL="TDFDX"
TOKEN_TOTAL_SUPPLY=888888888
ADMIN=0xbC7c091f89cd344D0575F3aA05b103bF748fEee1
SUPPLY_REMAINDER_RECIPIENT=0xbC7c091f89cd344D0575F3aA05b103bF748fEee1
UNISWAP_V2_ROUTER_ADDR=0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3
UNISWAP_V2_FACTORY_ADDR=0xF62c03E08ada871A0bEb309762E260a7a6a880E6
UNISWAP_V3_POSITION_MANAGER_ADDR=0x1238536071E1c677A632429e3655c799b22cDA52
UNISWAP_V2_LIQUIDITY_LOCKER=0x3075530A0524c2cAeb80Ac44A2cBAd15C82eb946
RPC_URL="YOUR_SEPOLIA_RPC_URL_HERE"
WETH_ADDR=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
LOCK_DURATION_DAYS=365
ETHERSCAN_API_KEY="YOUR_ETHERSCAN_API_KEY_HERE"
```

> ⚠️ **Critical Requirements**:
> 
> 1. Replace `YOUR_SEPOLIA_RPC_URL_HERE` with your own Sepolia RPC URL
> 2. Replace `YOUR_ETHERSCAN_API_KEY_HERE` with your own Etherscan API key (needed for contract verification)
> 3. Ensure the `ADMIN` address has Sepolia ETH - this is essential for deployment and protocol activation
> 4. The contract addresses for Uniswap components are verified Sepolia deployments - do not modify them

For mainnet deployments, you'll need a similar configuration file at `.env/mainnet.env` with production values.

### B. Secrets Management
-------------------

DLMP implements a robust secrets management system to protect private keys. Before deployment, you must create and manage keystores to securely handle private keys.

```bash
make secrets
```

This launches the interactive secrets management tool:

```
./management/scripts/secrets_management.sh
Key Management Menu:
1) Create a new keystore
2) Remove an existing keystore
3) List all keystores
4) Reveal a keystore address
5) Exit
Enter your choice (1-5): 
```

To prepare for deployment:

1. **Create a new keystore** - Select option 1 and follow the prompts to securely store your deployment key
2. **Name your keystore** - Use a descriptive name (e.g., `sepolia_deployer` or `mainnet_deployer`)
3. **Verify keystore creation** - Select option 3 to confirm your keystore appears in the list
4. **Check the associated address** - Select option 4 to verify the keystore has the expected public address

> 💡 **Security Tip**: For mainnet deployments, consider using hardware wallets or multi-signature wallets for the `ADMIN` role. The deployment pipeline works with these solutions through appropriate keystores.

## 6.2 Deployment Workflow

### A. The Deployment Pipeline
-------------------

DLMP's deployment process follows a comprehensive pipeline that enforces testing, security checks, and explicit confirmation before deployment.

To start the deployment process:

```bash
make deploy
```

This initiates a guided workflow that:

1. **Validates environment configuration**
2. **Runs comprehensive test suite**
3. **Verifies code coverage meets minimum thresholds**
4. **Performs security analysis**
5. **Displays architecture overview**
6. **Handles network selection and deployment**

Let's walk through each step of this process.

### B. Pre-Deployment Validation
-------------------

The deployment script first validates your environment and runs tests to ensure everything is working correctly:

```
[INFO] Validating environment...
[SUCCESS] Environment validated successfully.
🚀 Protocol Deployment Pipeline
Running Tests & Coverage Analysis...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### Coverage Requirements

The script enforces minimum coverage thresholds to ensure code quality:

```
📊 Coverage Report:
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Lines........: 98.01% (min: 85%)
Statements...: 98.05% (min: 85%)
Branches.....: 96.55% (min: 85%)
Functions....: 96.67% (min: 85%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SUCCESS] ✅ All tests passed and coverage requirements met!
```

If any coverage metric falls below 85%, the deployment will abort with an error message highlighting which areas need improvement.

### C. Security Analysis
-------------------

After successful testing, the script proceeds to security analysis:

```
Running Security Analysis Tools...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Select Security Analysis Tool:
1) Slither - Static analysis for Solidity vulnerabilities
2) Aderyn - Smart contract security scanner
3) All - Run both Slither and Aderyn
Enter your choice (1-3): 
```

For production deployments, option 3 (All) is strongly recommended.

#### Handling Security Findings

If issues are detected, the script will display them and ask for explicit acknowledgment:

```
[WARN] Slither found issues. Review the report above.
[INFO] Running Aderyn Security Analysis...
[WARN] Aderyn found issues!
# High Issues (1)
  - ## H-1: Contract locks Ether without a withdraw function.
[ERROR] High severity issues found.
# Low Issues (3)
  - ## L-1: Centralization Risk for trusted owners
  - ## L-2: Missing checks for `address(0)` when assigning values to address state variables
  - ## L-3: Return value of the function call is not checked.
Would you like to [1] Cancel deployment or [2] Continue with known issues? (1/2):
```

If you proceed, you'll need to:
1. Document the known issues
2. Type 'ACKNOWLEDGE RISKS' to confirm you understand the implications

This creates an audit trail of security decisions and ensures issues aren't overlooked.

### D. Network Selection and Deployment
-------------------

After security analysis, you'll select the target network:

```
Select deployment target:
1) Sepolia Testnet
2) Ethereum Mainnet
Enter your choice (1-2): 
```

For mainnet deployments, you'll need an additional confirmation:

```
⚠️ Type 'MAINNET' to confirm or 'exit' to cancel: MAINNET
```

#### Protocol Architecture Review

Next, the script provides an overview of the protocol structure for final review:

```
Protocol Architecture Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
activator (2 contracts)
  ├─ IProtocolActivator.sol (Interface)
  ├─ ProtocolActivator.sol
common (7 contracts)
...
```

#### Final Deployment Steps

After reviewing the pre-deployment checklist, you'll:

1. Confirm the deployment script location
2. Select which keystore to use for deployment
3. Enter the keystore password when prompted

Confirm the deployment script details:

```
Enter deployment script location (default: script/deploy/Deploy.s.sol): 
Enter contract name to deploy (default: Deploy): 
```

> 💡 **Pro Tip**: Simply press Enter for both prompts to use the default values, which are correctly configured for the protocol deployment.

⚠️ **CRITICAL WARNING**: Only use the provided deployment script (`Deploy.s.sol`)! This script has been meticulously engineered to ensure proper execution order, correct permission assignment, and secure role distribution within the protocol architecture. Using custom deployment scripts may result in security vulnerabilities, broken permissions, or compromised protocol functionality.

The deployment script (`Deploy.s.sol`) handles several critical operations:
* Loading configuration from environment variables
* Deploying all protocol contracts in the correct sequence
* Initializing components with proper permissions and relationships
* Establishing the security architecture with appropriate role boundaries
* Setting up unidirectional privilege flow (critical for security)

The order of operations in this script isn't arbitrary – it establishes the foundation of your protocol's security model. Each step builds upon the previous one to create a cohesive, secure system with properly isolated components. 🛡️

After script confirmation, you'll select your keystore and begin the actual deployment process:

```
[INFO] Using deployment script: script/deploy/Deploy.s.sol
[INFO] Using contract: Deploy
[INFO] Initiating deployment to Mainnet...
Available keystores:
dev_key (Local)
Enter deployment keystore name: 
```

## 6.3 Post-Deployment Operations

### A. Deployment Verification
-------------------

After successful deployment, the script will:

1. **Display deployed contract addresses**
2. **Verify contracts on Etherscan** (if ETHERSCAN_API_KEY was provided)
3. **Save deployment information** for future reference

Verify that all contracts have been deployed and verified correctly before proceeding to protocol activation.

### B. Protocol Activation
-------------------

Deploying the protocol and activating it are separate operations. This separation provides an additional safety check and allows time for verification before making the protocol operational.

Protocol activation includes:
- Creating liquidity pools
- Setting up initial token liquidity
- Configuring locking parameters

Detailed activation instructions will be covered in the next section.

### C. Security Best Practices
-------------------

When deploying to production, follow these critical security practices:

1. **Use multi-signature wallets** for the ADMIN_ROLE
2. **Store private keys in hardware wallets** where possible
3. **Document every deployment** including configuration and contract addresses
4. **Verify all contracts** on Etherscan after deployment
5. **Monitor gas prices** and select optimal deployment times
6. **Backup keystores** in secure, offline locations
7. **Conduct multiple dry runs** on testnets before mainnet deployment
8. **Perform third-party audits** of the codebase before significant deployments

By following this comprehensive deployment guide, you'll ensure a secure, well-validated implementation of the DLMP protocol across both test and production environments. The next section will cover protocol activation and management after deployment. 🚀