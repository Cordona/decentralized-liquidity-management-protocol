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
    - [B. Security Best Practices](#b-security-best-practices)
- [7. Protocol Activation Guide](#7-protocol-activation-guide)
  - [7.1 Understanding Protocol Activation](#71-understanding-protocol-activation)
    - [7.1.1 The Two-Phase Deployment Model](#711-the-two-phase-deployment-model)
    - [7.1.2 What Happens During Activation](#712-what-happens-during-activation)
  - [7.2 Pre-Activation Requirements](#72-pre-activation-requirements)
    - [7.2.1 Contract Prerequisites](#721-contract-prerequisites)
    - [7.2.2 Token \& Resource Requirements](#722-token--resource-requirements)
  - [7.3 Running the Activation Workflow](#73-running-the-activation-workflow)
    - [7.3.1 Activation Script Overview](#731-activation-script-overview)
    - [7.3.2 Contract Discovery Options](#732-contract-discovery-options)
    - [7.3.3 Parameter Collection Process](#733-parameter-collection-process)
    - [7.3.4 Pre-Activation Validation](#734-pre-activation-validation)
  - [7.4 Configuration Reference](#74-configuration-reference)
    - [7.4.1 Network Settings](#741-network-settings)
    - [7.4.2 Liquidity Parameters](#742-liquidity-parameters)
    - [7.4.3 Technical Parameters](#743-technical-parameters)
    - [7.4.4 Activation Scope Options](#744-activation-scope-options)
  - [7.5 Security Considerations](#75-security-considerations)
    - [7.5.1 One-Time Operation Warning](#751-one-time-operation-warning)
    - [7.5.2 External Service Fees](#752-external-service-fees)
    - [7.5.3 Keystore Management](#753-keystore-management)
  - [7.6 Post-Activation Verification](#76-post-activation-verification)
    - [7.6.1 Transaction Verification](#761-transaction-verification)
    - [7.6.2 Protocol State Verification](#762-protocol-state-verification)
    - [7.6.3 Using Protocol Manager View Functions](#763-using-protocol-manager-view-functions)
      - [1. Check V2 Liquidity Details](#1-check-v2-liquidity-details)
      - [2. Check V3 Liquidity Details](#2-check-v3-liquidity-details)
      - [3. Check Liquidity Lock Details (if enabled)](#3-check-liquidity-lock-details-if-enabled)
    - [7.6.4 Next Steps After Successful Verification](#764-next-steps-after-successful-verification)
- [8. Protocol Manager: The DLMP Gateway](#8-protocol-manager-the-dlmp-gateway)
  - [8.1 What is the Protocol Manager?](#81-what-is-the-protocol-manager)
  - [8.2 Core Capabilities](#82-core-capabilities)
    - [8.2.1 Protocol Activation](#821-protocol-activation)
      - [Why This Matters](#why-this-matters)
      - [Technical Implications](#technical-implications)
    - [8.2.2 Liquidity Monitoring](#822-liquidity-monitoring)
    - [8.2.3 Token Supply Management](#823-token-supply-management)
- [9. Emergency Token Recovery System](#9-emergency-token-recovery-system)
  - [9.1 Why Token Rescue Exists](#91-why-token-rescue-exists)
  - [9.2 Architecture \& Design Principles](#92-architecture--design-principles)
  - [9.3 Role-Based Security Model](#93-role-based-security-model)
  - [9.4 How Token Rescue Works](#94-how-token-rescue-works)
  - [9.5 Audit Trail \& Transparency](#95-audit-trail--transparency)
  - [9.6 When to Use Token Rescue](#96-when-to-use-token-rescue)
  - [9.9 Security Considerations](#99-security-considerations)
- [10. Role Management](#10-role-management)
  - [10.1 Transferring Administrative Control](#101-transferring-administrative-control)
    - [10.1.1 Changing the Protocol Manager Administrator](#1011-changing-the-protocol-manager-administrator)
    - [10.1.2 Changing the Emergency Recovery Role](#1012-changing-the-emergency-recovery-role)
  - [10.2 Role Management Best Practices](#102-role-management-best-practices)
    - [10.2.1 Protocol Administration](#1021-protocol-administration)
    - [10.2.2 Emergency Recovery](#1022-emergency-recovery)
  - [10.3 Understanding the Complete Role Hierarchy](#103-understanding-the-complete-role-hierarchy)
- [11. Audit Information: Deployment and Activation Status](#11-audit-information-deployment-and-activation-status)
  - [11.1 Overview for Auditors](#111-overview-for-auditors)
  - [2. Deployment Addresses](#2-deployment-addresses)
    - [2.1 Core Protocol Components](#21-core-protocol-components)
    - [2.2 Protocol Deployment Transaction Hashes](#22-protocol-deployment-transaction-hashes)
    - [2.3 Test Pair Token](#23-test-pair-token)
    - [2.4 Test Pair Token Deployment Transaction Hash](#24-test-pair-token-deployment-transaction-hash)
    - [2.4 LP tokens](#24-lp-tokens)
  - [3. Protocol Activation Details](#3-protocol-activation-details)
    - [3.1 Activation Transaction Hashes](#31-activation-transaction-hashes)
    - [3.2 Activation Scope](#32-activation-scope)
  - [4. Contact Information for Audit Queries](#4-contact-information-for-audit-queries)

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
🔑 Protocol Manager (Gateway)
   │  Entry point for protocol operations
   ▼
⚙️ Protocol Activator (Orchestrator)
   │  Coordination layer for complex processes
   ▼
🧩 Component Layer (Executors)
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

- **Isolated Recovery Role** - The `TOKEN_RESCUER_ROLE` is separate from operational administrative roles, enforcing separation of concerns
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
* **Retains emergency recovery capabilities** via `TOKEN_RESCUER_ROLE`
* After deployment, becomes the **external admin** with limited, focused access

#### 2. Protocol Manager
Acts as the primary gateway and command center for the entire protocol:
* Functions as the single entry point for protocol operations
* Receives administrative control from the deployer
* Controls protocol activation through the ProtocolActivator
* Manages token supply remainder functionality
* Provides view functions for liquidity tracking across V2/V3 including V2 liquidity locking

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
The `TOKEN_RESCUER_ROLE` provides a safety net without compromising the main permission structure, allowing for emergency intervention if tokens need to be rescued from component contracts.

### Permission Models & State

After deployment, the protocol establishes the following permission state:

1. **Deployer**:
   - Retains `TOKEN_RESCUER_ROLE` for emergency recovery
   - Has `ADMIN_ROLE` only for the Protocol Manager
   - Cannot directly access factories or locker components

2. **Protocol Manager**:
   - Becomes the only entry point for protocol activation
   - Has exclusive `ADMIN_ROLE` for the Protocol Activator
   - Cannot directly operate factories or locker

3. **Protocol Activator**:
   - Has `ADMIN_ROLE` for V2Factory, V3Factory, and LiquidityLocker
   - Only responds to Protocol Manager commands
   - Orchestrates complex operations across multiple components

4. **Factory & Locker Components**:
   - Only respond to Protocol Activator commands
   - Cannot interact with other components independently
   - Provide emergency token recovery via `TOKEN_RESCUER_ROLE`

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

- **`manager/`** - This is our entry point to the protocol! Contains `ProtocolManager.sol` which serves as the gateway for all external operations. If you're integrating with the protocol, start here. 🚪

- **`activator/`** - Contains `ProtocolActivator.sol` which orchestrates complex multi-step operations across different components. Think of this as the conductor of our protocol symphony. 🎮

- **`factories/`** - Houses our Uniswap integration components:
  - `v2/` - Implements the Uniswap V2 pool creation and management
  - `v3/` - Handles Uniswap V3 concentrated liquidity positions
  
- **`locker/`** - Contains `LiquidityLocker.sol` which handles our UNCX integration for secure liquidity locking. A critical component for establishing trust in the protocol. 🔒

#### Foundation Components

- **`common/`** - The backbone of the protocol with shared utilities:
  - `AdminInitializer.sol` - Manages admin role transitions and initialization
  - `BaseProtocol.sol` - Core validation and common error definitions
  - `RoleBased.sol` - Enhanced role management extending OpenZeppelin's AccessControl
  - `Roles.sol` - Security role definitions (`ADMIN_ROLE`, `TOKEN_RESCUER_ROLE`)
  - `Types.sol` - Shared data structures for protocol configuration
  - `Utils.sol` - Helper functions for token operations and address manipulations
  - `V3Constants.sol` - Uniswap V3-specific constants for pool creation

- **`initializer/`** - Contains the module initialization system that establishes secure role transitions between components.

- **`rescuer/`** - Implements our emergency recovery system for handling unexpected situations. A crucial safety net for the protocol. 

- **`token/`** - Contains the implementation of our ERC20 token standard and WETH interface. The foundation of our liquidity operations.

#### Component Relationships

Our architecture follows a layered approach with clear boundaries:

1. **External interface** (`manager/`) - Where external calls enter the system
2. **Orchestration layer** (`activator/`) - Coordinates operations
3. **Execution components** (`factories/`, `locker/`) - Perform specific tasks

This separation creates a secure, maintainable codebase where components have clearly defined responsibilities and permissions. 

#### Interface Pattern

Notice how most modules follow an interface/implementation pattern (e.g., `IProtocolManager.sol`/`ProtocolManager.sol`). This pattern:

- Enables clear API definitions
- Supports potential upgradability
- Enforces separation of concerns
- Makes the code more testable

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
ADMIN=0xFa377a04AFc78d158bCD59E9eFeDa07b3d89c7A3
SUPPLY_REMAINDER_RECIPIENT=0x9437f4c817C89571706BFe258957bf4B0ca9d6b7
UNISWAP_V2_ROUTER_ADDR=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
UNISWAP_V2_FACTORY_ADDR=0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
UNISWAP_V3_POSITION_MANAGER_ADDR=0xC36442b4a4522E871399CD717aBDD847Ab11FE88
UNISWAP_V2_LIQUIDITY_LOCKER=0x59d7D55DdC58494FbBbca29904f108ece82Ac7FB
RPC_URL=YOUR_MAINNET_RPC_URL
WETH_ADDR=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
LOCK_DURATION_DAYS=365
```

> 💡 **Important Note**: You must replace `YOUR_MAINNET_RPC_URL` with your own Ethereum mainnet RPC URL (from providers like Alchemy, Infura, or your own node). Our test suite runs against a mainnet fork to ensure realistic testing conditions.

The contract addresses provided above (`UNISWAP_V2_ROUTER_ADDR`, `UNISWAP_V2_FACTORY_ADDR`, etc.) are actual mainnet deployed contracts. **You should not change these values** for local testing since our fork-based tests expect to interact with these specific contracts. Also. do not change `ADMIN` and `SUPPLY_REMAINDER_RECIPIENT` - these values are aligned with our test configuration. 

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

🚀  Script Deployment:  
  make deploy-script - Guided deployment script execution
    ├─ Prompts for deployment script path
    ├─ Collects contract name and deployer address
    ├─ Validates keystore and RPC configuration
    ├─ Supports Etherscan verification
    ├─ Ensures correct contract deployment settings
    ├─ Provides a final confirmation step
    └─ Executes deployment via Foundry (forge script)

🚀  Protocol Deployment:  
  make deploy-protocol - Interactive deployment workflow
    ├─ Supports both Sepolia and Mainnet
    ├─ Includes contract verification
    └─ Loads network-specific configurations

⚡  Protocol Activation:  
  make activate     - Execute the activation workflow for deployed contracts
    ├─ Discovers deployed contract addresses
    ├─ Collects required activation parameters
    ├─ Ensures necessary approvals and balance checks
    ├─ Supports interactive and automated execution modes
    ├─ Validates protocol readiness before activation
    ├─ Runs network-specific activation on Sepolia or Mainnet
    ├─ Provides execution logs and confirmation prompts
    └─ Ensures activation cannot be re-executed post-success

💡  Development Tips:  
  1. Always run 'make dependencies' after cloning the repo
  2. Ensure environment files are configured:
     ├─ .env/test.env for local fork testing at mainnet
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
   make test → make coverage → make analyze → make deploy-protocol
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
ADMIN=YOUR_ADMIN_ADDRESS
SUPPLY_REMAINDER_RECIPIENT=YOUR_SUPPLY_REMAINDER_RECIPIENT
UNISWAP_V2_ROUTER_ADDR=0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3
UNISWAP_V2_FACTORY_ADDR=0xF62c03E08ada871A0bEb309762E260a7a6a880E6
UNISWAP_V3_POSITION_MANAGER_ADDR=0x1238536071E1c677A632429e3655c799b22cDA52
UNISWAP_V2_LIQUIDITY_LOCKER=0x3075530A0524c2cAeb80Ac44A2cBAd15C82eb946
RPC_URL=YOUR_SEPOLIA_RPC_URL_HERE
WETH_ADDR=0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14
LOCK_DURATION_DAYS=365
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY
```

> ⚠️ **Critical Requirements**:
>
> 1. Replace `YOUR_ADMIN_ADDRESS` with admin address with sufficient Sepolia ETH
> 2. Replace `YOUR_SUPPLY_REMAINDER_RECIPIENT` with valid address
> 3. Replace `YOUR_SEPOLIA_RPC_URL` with your own Sepolia RPC URL
> 4. Replace `YOUR_ETHERSCAN_API_KEY` with your own Etherscan API key (needed for contract verification)
> 5. Ensure the `ADMIN` address has Sepolia ETH - this is essential for deployment and protocol activation
> 6. The contract addresses for Uniswap components are verified Sepolia deployments - do not modify them

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

> 💡 **Security Tip**: For mainnet deployments, consider using hardware wallets or multi-signature wallets for the `ADMIN` role.  
> Be extremely **cautious** when using multisig wallets—hackers can **social-engineer** their way in and exploit vulnerabilities.  
> **Research the $1.4B Bybit hack** and watch [Patrick Collins's video](https://youtu.be/Gf8_ovO-jBI?si=NZE0REQ5lVTRnYF4) explaining how this attack was executed despite the use of a multisig wallet.

## 6.2 Deployment Workflow

### A. The Deployment Pipeline
-------------------

DLMP's deployment process follows a comprehensive pipeline that enforces testing, security checks, and explicit confirmation before deployment.

To start the deployment process:

```bash
make deploy-protocol
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

You can define a custom coverage threshold for deployment. However, 85% is the recommended minimum for production deployments.
If you set a threshold below 85%, they must explicitly acknowledge the risk of deploying with insufficient test coverage.
If the actual test coverage falls below the user-defined threshold, the deployment script will abort and display an error message identifying which areas need improvement.

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
2. **Verify contracts on Etherscan** (`ETHERSCAN_API_KEY` **must** be provided)
3. **Save deployment information** for future reference

Verify that all contracts have been deployed and verified correctly before proceeding to protocol activation.

### B. Security Best Practices
-------------------

When deploying to production, follow these critical security practices:

1. **Use multi-signature wallets** for the `ADMIN_ROLE`
2. **Store private keys in hardware wallets** where possible
3. **Document every deployment** including configuration and contract addresses
4. **Verify all contracts** on Etherscan after deployment
5. **Monitor gas prices** and select optimal deployment times
6. **Backup keystores** in secure, offline locations
7. **Conduct multiple dry runs** on testnets before mainnet deployment
8. **Perform third-party audits** of the codebase before significant deployments

By following this comprehensive deployment guide, you'll ensure a secure, well-validated implementation of the DLMP protocol across both test and production environments. The next section will cover protocol activation and management after deployment. 🚀

# 7. Protocol Activation Guide

Protocol activation is the critical process that brings your deployed DLMP infrastructure to life. This guide walks you through the entire activation journey, from understanding the underlying principles to verifying successful implementation.

## 7.1 Understanding Protocol Activation

### 7.1.1 The Two-Phase Deployment Model

DLMP implements a deliberate separation between deployment and activation phases for enhanced security:

```
Phase 1: Contract Deployment → Verification Period → Phase 2: Protocol Activation
```

This separation provides several critical advantages:

- **Security Buffer** - Creates time for contract verification and audit before funds are committed
- **Risk Isolation** - Deployment failures don't risk liquidity assets
- **Operational Control** - Gives teams time to prepare token balances and marketing announcements
- **Governance Transition** - Allows transfer of control from technical deployer to operational team

By splitting the process, we want reduce the attack surface during the most vulnerable period - immediately after deployment.

### 7.1.2 What Happens During Activation

During activation, the protocol executes several critical operations:

1. **Factory Funding** - Protocol Token and Pair Token transfers to V2/V3 factories
2. **Pool Creation** - Establishing trading pairs on Uniswap V2/V3
3. **Liquidity Provision** - Seeding initial liquidity with calculated token amounts
4. **Liquidity Locking** - Securing V2 liquidity via UNCX (if enabled)
5. **State Transition** - One-way protocol state change to "Activated"

These operations establish your token's initial trading environment and create the foundation for its market health.

## 7.2 Pre-Activation Requirements

### 7.2.1 Contract Prerequisites

Before activation, ensure you have:

- ✅ Successfully deployed Protocol Manager
- ✅ Successfully deployed V2 Factory
- ✅ Successfully deployed V3 Factory
- ✅ Successfully deployed Protocol Token
- ✅ Correct role permissions assigned during deployment

You should have your `run-latest.json` file from deployment containing all contract addresses.

### 7.2.2 Token & Resource Requirements

The activating address must have:

| Resource       | Purpose                   | Notes                                            |
| -------------- | ------------------------- | ------------------------------------------------ |
| Protocol Token | Liquidity provision       | Needs 2× (per-pool amount × pools created)       |
| Pair Token     | Trading pair creation     | Commonly USDC, USDT, or DAI                      |
| ETH            | Gas fees + WETH liquidity | Plan for high gas usage (~15-20M gas)            |
| ETH            | UNCX locking fees         | 0.1 ETH per pool on mainnet, 0.01 ETH on testnet |
| ADMIN_ROLE     | Permission to activate    | Assigned during deployment                       |

> ⚠️ **Important**: The activating address MUST have the `ADMIN_ROLE` and sufficient token balances for ALL pools being created. Calculate your requirements carefully!

## 7.3 Running the Activation Workflow

### 7.3.1 Activation Script Overview

The protocol provides a specialized script (`activate_protocol.sh`) that orchestrates the entire activation process through an interactive workflow.

> ⚠️ **Critical Security Notice**: You MUST use the provided activation scripts (`activate_protocol.sh` and `ActivateProtocol.s.sol`). These scripts implement security best practices and enforce proper protocol interaction patterns that align with the architecture's design. Custom activation attempts may lead to security vulnerabilities, stuck tokens, or incomplete activation.

Prerequisites for running the script:
- Foundry toolkit installed (`forge`, `cast`)
- Bash environment
- `jq` for JSON parsing

Run the make command:
```bash
make activate-protocol
```

### 7.3.2 Contract Discovery Options

The script offers three methods to locate your deployed contracts:

**Option 1: Using deployment JSON** (Recommended)
```
Select discovery method: 1
Enter path to run-latest.json: ./broadcast/Deploy.s.sol/11155111/run-latest.json
```
This is the most reliable method as it directly uses your deployment artifacts.

**Option 2: Manual address entry**
```
Select discovery method: 2
Enter Protocol Token address: 0x...
Enter Protocol Manager address: 0x...
# ...and so on
```
Use this when deployment artifacts aren't available.

**Option 3: Auto-discovery**
```
Select discovery method: 3
```
The script searches common locations for deployment artifacts.

### 7.3.3 Parameter Collection Process

The script guides you through five configuration areas:

1. **Admin Configuration** - Who will execute activation
   ```
   Enter admin address (with ADMIN_ROLE): 0x...
   ```

2. **Token Configuration** - Which tokens to use for pools
   ```
   Enter Pair Token address (e.g. USDC): 0x...
   Enter WETH address [press Enter for default]: 
   Enter Liquidity Tokens Recipient address: 0x...
   ```

3. **Liquidity Configuration** - How much liquidity to provide
   ```
   Enter Protocol Token liquidity amount(per pool): 2000000
   Enter Pair Token liquidity amount (per pool): 10000000
   Enter WETH liquidity amount (in ETH, not wei, per pool): 1
   ```

4. **Technical Parameters** - Pool settings
   ```
   Select fee tier (1-4) [press Enter for default (3)]: 4
   Enter deadline in seconds [press Enter for default]: 500
   ```

5. **Activation Scope** - Which features to enable
   ```
   Create Uniswap V2 pools? (y/n): y
   Create Uniswap V3 pools? (y/n): y
   Lock Uniswap V2 liquidity? (y/n): y
   ```

### 7.3.4 Pre-Activation Validation

The script performs comprehensive validation before execution:

```
📋 COMPLETE ACTIVATION CONFIGURATION
■ DISCOVERED CONTRACTS
  • Protocol Token:       0xddea30fec...
  • Protocol Manager:     0xc9bd53db...
  • V2 Factory:           0xd7d8fb21...
  • V3 Factory:           0x8dc2e327...

■ USER CONFIGURATION
  • Admin Address:        0xbC7c091f...
  • Pair Token:           0x78c95fe6...
  • WETH Address:         0xfFf99767...
  • Liquidity Recipient:  0xbC7c091f...

# ... and more
```

This validation ensures you have a complete understanding of what will happen during activation.

## 7.4 Configuration Reference

### 7.4.1 Network Settings

| Setting  | Description                       | Example                                         |
| -------- | --------------------------------- | ----------------------------------------------- |
| RPC URL  | Network endpoint for transactions | `https://eth-sepolia.g.alchemy.com/v2/YOUR-KEY` |
| Chain ID | Network identifier                | `1` (Mainnet), `11155111` (Sepolia)             |

> 💡 **Tip**: Using a private RPC endpoint (like Alchemy or Infura) provides more reliable transaction execution than public endpoints.

### 7.4.2 Liquidity Parameters

| Parameter             | Description     | Recommendation                                        |
| --------------------- | --------------- | ----------------------------------------------------- |
| Protocol Token Amount | Amount per pool | Calculate based on desired initial price              |
| Pair Token Amount     | Amount per pool | Balance with Protocol Token for target price          |
| WETH Amount           | ETH per pool    | Usually 0.5-2 ETH for testnets, 2-10+ ETH for mainnet |

### 7.4.3 Technical Parameters

| Parameter   | Description            | Options                                                      |
| ----------- | ---------------------- | ------------------------------------------------------------ |
| V3 Fee Tier | Trading fee percentage | 0.01% (stable), 0.05% (stable), 0.3% (standard), 1% (exotic) |
| Deadline    | Transaction expiration | 500-3600 seconds (longer for congested networks)             |

### 7.4.4 Activation Scope Options

| Option            | Description              | Considerations                             |
| ----------------- | ------------------------ | ------------------------------------------ |
| Create V2 Pools   | Standard liquidity pools | Good for general trading, easier for users |
| Create V3 Pools   | Concentrated liquidity   | More capital-efficient, complex for users  |
| Lock V2 Liquidity | UNCX liquidity locking   | Builds trust, requires fees                |

## 7.5 Security Considerations

### 7.5.1 One-Time Operation Warning

> ⚠️ **CRITICAL**: Protocol activation is a **ONE-TIME OPERATION**. Once successfully executed, it cannot be repeated or reversed.

This finality is by design and provides several benefits:
- Prevents double-liquidity creation
- Establishes clear market initialization point
- Enforces proper protocol lifecycle management

However, it means you must:
- Triple-check all parameters before confirmation
- Ensure sufficient resources for the operation
- Have contingency plans in case of network issues

### 7.5.2 External Service Fees

UNCX liquidity locking requires fees paid to the UNCX service:

| Network | Fee per Pool | Total for 2 Pools | Notes             |
| ------- | ------------ | ----------------- | ----------------- |
| Mainnet | ~0.1 ETH     | ~0.2 ETH          | Subject to change |
| Sepolia | ~0.01 ETH    | ~0.02 ETH         | May vary          |

To verify current fees:

```bash
cast call 0x3075530A0524c2cAeb80Ac44A2cBAd15C82eb946 \
"gFees()(uint256,address,uint256,uint256,uint256,uint256,address,uint256,uint256)" \
--rpc-url YOUR_RPC_URL
```

The first value returned is the fee in wei.

### 7.5.3 Keystore Management

For a successful activation you must have a private key generated with our `make-secrets` command

## 7.6 Post-Activation Verification

### 7.6.1 Transaction Verification

First, confirm all transactions succeeded (as shown in your terminal output):

```
##### sepolia
✅ [Success] Hash: 0x1be698e3a4c773763b1fd0beffe5acef7fc7a0f2ee3c16ce6e57b9bb0629adfe
...
✅ [Success] Hash: 0xaa52a61105e31450e2c12de150c3602129e69d7792b4237c2776b1ce12b48a40
```

The pattern we expect to see is:
1. Four smaller transactions (~51K gas each) - These are token transfers to the factories
2. One larger transaction (~16.7M gas) - This is the main activation call

All transactions should show `[Success]` status. If any transaction failed, the activation would be incomplete.

### 7.6.2 Protocol State Verification

```bash
# Check if protocol is activated (this can be called on the ProtocolActivator)
cast call <PROTOCOL-ACTIVATOR-ADDRESS> "s_activated()(bool)" --rpc-url <YOUR-RPC-URL>
# Should return: true
```

### 7.6.3 Using Protocol Manager View Functions

The Protocol Manager provides specialized functions to verify all aspects of activation:

#### 1. Check V2 Liquidity Details

```bash
# Format: getV2LiquidityDetails(tokenA, tokenB, liquidityOwner)
cast call PROTOCOL_MANAGER_ADDRESS "getV2LiquidityDetails(address,address,address)(address,uint256)" \
  PROTOCOL_TOKEN_ADDRESS PAIR_TOKEN_ADDRESS LIQUIDITY_RECIPIENT_ADDRESS
```

This returns:
- `address liquidityToken`: The LP token address
- `uint256 liquidity`: The amount of LP tokens received

> 💡If you activated the protocol with V2 liquidity locking, you should expect a `0` value for the LP tokens
> Use the ProtocolActivator's address for `LIQUIDITY_RECIPIENT_ADDRESS`. 
> More details - in the contract's natspec documentation

#### 2. Check V3 Liquidity Details

```bash
# Format: getV3LiquidityDetails(liquidityOwner)
cast call PROTOCOL_MANAGER_ADDRESS "getV3LiquidityDetails(address)(uint256,uint128,uint24)" \
  LIQUIDITY_RECIPIENT_ADDRESS
```

This returns:
- `uint256 tokenId`: The NFT position ID
- `uint128 liquidity`: Amount of liquidity in the position
- `uint24 fee`: The fee tier (should match what you selected during activation)

#### 3. Check Liquidity Lock Details (if enabled)

```bash
# First, get the LP token address from getV2LiquidityDetails
# Then: getLiquidityLockDetails(owner, lpToken)
cast call PROTOCOL_MANAGER_ADDRESS "getLiquidityLockDetails(address,address)(uint256,uint256,uint256,uint256,uint256,address)" \
  LIQUIDITY_RECIPIENT_ADDRESS LP_TOKEN_ADDRESS
```
> Use the ProtocolActivator's address for `LIQUIDITY_RECIPIENT_ADDRESS`. 
> More details - in the contract's natspec documentation

This returns comprehensive lock information:
- `uint256 lockDate`: When the lock was created (timestamp)
- `uint256 amount`: Amount of LP tokens locked
- `uint256 initialAmount`: Initial lock amount
- `uint256 unlockDate`: When tokens become unlockable (timestamp)
- `uint256 lockId`: Unique identifier in UNCX system
- `address owner`: Who can unlock the tokens

### 7.6.4 Next Steps After Successful Verification

After confirming successful activation:

1. **Document All Addresses** - Save all contract and pool addresses for future reference
2. **Monitor Price Performance** - Watch initial trading activity and price discovery
3. **Consider Additional Liquidity** - Evaluate if more liquidity is needed based on trading volume
4. **Begin Marketing Activities** - Now that trading is live, launch planned marketing initiatives
5. **Prepare Monitoring Tools** - Set up alerts for significant liquidity changes or trading anomalies

By leveraging the Protocol Manager's built-in verification functions, you get the most accurate and direct confirmation of successful activation without relying on third-party interfaces. This approach ensures you have cryptographic proof that all protocol components are correctly configured and operational! 🛡️

# 8. Protocol Manager: The DLMP Gateway

Let's explore the Protocol Manager - the central control hub that makes our entire system work securely and efficiently. Think of it as the "front door" to your protocol.

## 8.1 What is the Protocol Manager?

The Protocol Manager serves as the single entry point for all important protocol operations. 

```
External World → Protocol Manager → Protocol Components
```

Why this matters:
- Creates a single, secure entry point that's easier to protect
- Establishes clear permission boundaries
- Makes the system easier to understand and audit
- Prevents direct tampering with internal components

## 8.2 Core Capabilities

### 8.2.1 Protocol Activation

The Manager's primary job is to coordinate the protocol activation process:

```solidity
function activate(PoolConfig calldata config, ActivationScope calldata scope)
    external
    payable
    nonReentrant
    onlyRole(Roles.ADMIN_ROLE)
```

This function:
- Takes your configuration parameters
- Forwards ETH for pool creation and locking fees
- Orchestrates the deployment of liquidity across Uniswap V2/V3
- Ensures only authorized admins can trigger activation

> ⚠️ **CRITICAL SECURITY NOTICE**: Always activate the protocol using the official activation workflow detailed in Section 7 (Protocol Activation Guide). Never attempt to call the `activate()` function directly or create custom activation scripts.

#### Why This Matters

The official activation workflow isn't just a convenience—it's a critical security layer that:

1. **Performs essential pre-checks** - Validates token approvals, balances, and permissions
2. **Calculates precise token amounts** - Ensures correct distribution of tokens to factory components
3. **Manages complex transaction sequences** - Handles factory funding before activation in the correct order
4. **Prevents partial activation** - Custom approaches risk leaving your protocol in an inconsistent state

Think of our activation workflow like a flight pre-check system—it ensures everything is in perfect order before the critical "takeoff" moment of your protocol launch. 🚀

#### Technical Implications

Attempting to bypass the official activation process could lead to:
- Tokens being stuck in contracts without proper pool creation
- Liquidity positions being created without proper locking
- Security roles not being correctly validated
- Transaction failures at unpredictable points in the sequence

The `activate_protocol.sh` script and `ActivateProtocol.s.sol` contract were carefully engineered to work in tandem with the Protocol Manager, creating a secure, predictable activation experience that protects your assets and ensures proper protocol initialization.

Always refer to Section 7 for the complete, step-by-step activation guide. Your protocol's security and functionality depend on following this established path! 🔐

### 8.2.2 Liquidity Monitoring

After activation, the Manager becomes your window into your protocol's health:

```solidity
// Check V2 liquidity positions
function getV2LiquidityDetails(address tokenA, address tokenB, address liquidityOwner)
    external view returns (address liquidityToken, uint256 liquidity)

// Check V3 positions
function getV3LiquidityDetails(address liquidityOwner)
    external view returns (uint256 tokenId, uint128 liquidity, uint24 fee)

// Check liquidity locks
function getLiquidityLockDetails(address _owner, address _lpToken)
    external view returns (...)
```

These functions let you:
- Monitor your liquidity positions across both Uniswap versions
- Verify lock status and unlock timing
- Build monitoring dashboards and alerts

### 8.2.3 Token Supply Management

The Manager also helps handle any remaining tokens after launch:

```solidity
function transferSupplyRemainder(address owner) 
    external onlyRole(Roles.ADMIN_ROLE)
```

This streamlines post-launch token distribution and treasury management.

# 9. Emergency Token Recovery System

## 9.1 Why Token Rescue Exists

Every DeFi protocol needs a safety net. Despite careful design, tokens can sometimes get stuck in contracts due to:

- Unexpected edge cases in transaction sequences
- User errors when interacting with the protocol
- Protocol upgrade scenarios with balance transitions
- External protocol integration changes

We use a dedicated token rescue system that's:
- **Intentionally isolated** from the main protocol flow
- **Role-restricted** to prevent unauthorized access
- **Transparently auditable** through event emissions

## 9.2 Architecture & Design Principles

```
TokenRescuer (Abstract Contract)
     ↓
   extends
     ↓
Protocol Components (V2/V3 Factories)
```

The TokenRescuer functionality is intentionally **not** implemented in the Protocol Manager. This architectural decision creates important security boundaries:

```solidity
// TokenRescuer.sol (abstract contract)
abstract contract TokenRescuer is BaseProtocol {
    // Emergency rescue functionality
    function rescueTokens(address tokenA, address tokenB, address to)
        external
        virtual
        onlyRole(Roles.TOKEN_RESCUER_ROLE)
        validAddress(tokenA)
        validAddress(tokenB)
        validAddress(to)
    {
        // Rescue implementation
    }
}
```

Key design decisions:
1. **Separation of Concerns**: Rescue functionality lives in component contracts, not the gateway
2. **Privilege Isolation**: Uses dedicated `TOKEN_RESCUER_ROLE` separate from `ADMIN_ROLE`
3. **Implementation via Extension**: Components inherit from TokenRescuer abstract contract
4. **Dual-Token Recovery**: Always rescues pairs of tokens to handle LP scenarios

## 9.3 Role-Based Security Model

The TOKEN_RESCUER_ROLE is a specialized permission that:

1. Is initially granted to the deployer in the constructor:
   ```solidity
   constructor() {
       _grantRole(Roles.TOKEN_RESCUER_ROLE, msg.sender);
   }
   ```

2. Can be transferred to a new address when needed:
   ```solidity
   function changeRescuer(address newRescuer) 
       external 
       onlyRole(Roles.TOKEN_RESCUER_ROLE) 
       validAddress(newRescuer)
   {
       grantRole(Roles.TOKEN_RESCUER_ROLE, newRescuer);
       revokeRole(Roles.TOKEN_RESCUER_ROLE, msg.sender);
       emit NewTokensRescuer(newRescuer);
   }
   ```

This creates a clean security boundary between:
- **Operational Administration** (`ADMIN_ROLE`) - Day-to-day protocol operations
- **Emergency Recovery** (`TOKEN_RESCUER_ROLE`) - Last-resort intervention

## 9.4 How Token Rescue Works

The rescue process itself is straightforward:

```solidity
function rescueTokens(address tokenA, address tokenB, address to)
    external
    virtual
    onlyRole(Roles.TOKEN_RESCUER_ROLE)
    validAddress(tokenA)
    validAddress(tokenB)
    validAddress(to)
{
    uint256 rescuedTokenBalanceA = IERC20(tokenA).balanceOf(address(this));
    uint256 rescuedTokenBalanceB = IERC20(tokenB).balanceOf(address(this));

    emit TokensRescued(tokenA, tokenB, to, rescuedTokenBalanceA, rescuedTokenBalanceB);

    IERC20(tokenA).safeTransfer(to, rescuedTokenBalanceA);
    IERC20(tokenB).safeTransfer(to, rescuedTokenBalanceB);
}
```

The function:
1. Checks the current balance of both tokens in the contract
2. Emits a detailed event recording the rescue operation
3. Transfers the entire balance of both tokens to the recipient
4. Uses SafeERC20 to handle non-standard tokens securely

## 9.5 Audit Trail & Transparency

Every rescue operation emits a detailed `TokensRescued` event:

```solidity
event TokensRescued(
    address indexed tokenA, 
    address indexed tokenB, 
    address indexed to, 
    uint256 liquidityA, 
    uint256 liquidityB
);
```

This provides crucial information for:
- Forensic analysis of rescue operations
- Reconciliation of token movements
- Operational transparency for users and stakeholders

The `NewTokensRescuer` event provides visibility into role transitions:

```solidity
event NewTokensRescuer(address indexed newTokenRescuer);
```

## 9.6 When to Use Token Rescue

The rescue functionality is designed for exceptional circumstances:

| Appropriate Use Cases                 | Inappropriate Use Cases |
| ------------------------------------- | ----------------------- |
| Tokens accidentally sent to contracts | Regular token transfers |
| Recovery after failed operations      | Protocol rebalancing    |
| Rescuing during contract upgrades     | Fee collection          |
| Emergency evacuation scenarios        | Routine operations      |


## 9.9 Security Considerations

When working with token rescue functionality:

1. **Immediate Role Transfer**: Consider transferring `TOKEN_RESCUER_ROLE` to a secure multi-sig after deployment
   ```solidity
   // After deployment
   tokenRescuer.changeRescuer(secureMultiSigAddress);
   ```

2. **Incident Response Plan**: Establish clear procedures for when rescue operations are authorized

3. **Event Monitoring**: Set up alerts for TokensRescued events to detect unplanned rescues

4. **Address Validation**: Double-check recipient addresses before executing rescues

5. **Dual Control**: Implement governance controls requiring multiple approvals before rescue

# 10. Role Management

## 10.1 Transferring Administrative Control

### 10.1.1 Changing the Protocol Manager Administrator

To transfer the `ADMIN_ROLE` to a new address (possible only for the Protocol Manager post deployment):

```solidity
function changeAdmin(address newAdmin) 
    external 
    onlyRole(Roles.ADMIN_ROLE) 
    validAddress(newAdmin) 
{
    grantRole(Roles.ADMIN_ROLE, newAdmin);
    revokeRole(Roles.ADMIN_ROLE, msg.sender);
    emit NewAdmin(newAdmin);
}
```

> 💡 **Important**: Once the `ADMIN_ROLE` is transferred, it cannot be taken back without the new admin's action. Always verify the new admin address carefully!

Example usage:
```javascript
// Transfer ADMIN_ROLE to a new address
// Only callable by current admin
await protocolManager.changeAdmin(newAdminAddress);
```

### 10.1.2 Changing the Emergency Recovery Role

Similarly, the `TOKEN_RESCUER_ROLE` can be transferred:

```solidity
function changeRescuer(address newRescuer) 
    external 
    onlyRole(Roles.TOKEN_RESCUER_ROLE) 
    validAddress(newRescuer) 
{
    grantRole(Roles.TOKEN_RESCUER_ROLE, newRescuer);
    revokeRole(Roles.TOKEN_RESCUER_ROLE, msg.sender);
    emit NewTokensRescuer(newRescuer);
}
```
Example usage:
```javascript
// Transfer TOKEN_RESCUER_ROLE to a secure multi-sig
// Only callable by current token rescuer
await v2PoolFactory.changeRescuer(multiSigWalletAddress);
```

## 10.2 Role Management Best Practices

When managing protocol roles, follow these security guidelines:

### 10.2.1 Protocol Administration

1. **Use Multi-Signature Wallets** - Transfer the `ADMIN_ROLE` to a multi-sig for operational security
   ```javascript
   // Best practice: move admin to multi-sig after deployment
   await protocolManager.changeAdmin(multiSigWalletAddress);
   ```

2. **Document Role Transfers** - Keep clear records of all role changes
   ```javascript
   // Monitor role changes
   protocolManager.on("NewAdmin", (admin) => {
     logSecurityEvent(`New admin assigned: ${admin}`);
   });
   ```

3. **Verify Role Assignments** - Regularly check that roles are correctly assigned
   ```javascript
   // Verification check
   const hasAdminRole = await protocolManager.hasRole(
     ADMIN_ROLE,
     expectedAdminAddress
   );
   console.assert(hasAdminRole, "Admin role assignment incorrect!");
   ```

### 10.2.2 Emergency Recovery

1. **Cold Storage for Rescuer** - Consider using a hardware wallet for the `TOKEN_RESCUER_ROLE`
   ```javascript
   // Transfer to hardware wallet address
   await v2PoolFactory.changeRescuer(hardwareWalletAddress);
   ```

2. **Role Verification** - After transfer, verify the role assignment was successful
   ```javascript
   // Verify TOKEN_RESCUER_ROLE transfer
   const hasRescuerRole = await v2PoolFactory.hasRole(
     TOKEN_RESCUER_ROLE,
     newRescuerAddress
   );
   console.assert(hasRescuerRole, "Rescuer role transfer failed!");
   ```

3. **Emergency Planning** - Create a documented process for when and how token rescue can be used
   ```javascript
   // Document rescue process in your operations manual
   // 1. Multi-sig confirmation of emergency
   // 2. Security team validation
   // 3. Execution through proper channels
   // 4. Post-rescue audit
   ```

## 10.3 Understanding the Complete Role Hierarchy

For a complete view of the protocol's role structure, refer to Section 4 (Security Architecture), which details how these roles cascade through the entire protocol:

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
# 11. Audit Information: Deployment and Activation Status

## 11.1 Overview for Auditors

The Decentralized Liquidity Management Protocol (DLMP) has been **fully deployed and activated** on the Sepolia testnet, with all core components operational including:

- Complete protocol deployment with proper role initialization
- Successful V2 and V3 pool creation and liquidity provisioning
- Active V2 liquidity locking via UNCX integration
- Test token deployment for audit verification

## 2. Deployment Addresses

### 2.1 Core Protocol Components

| Contract           | Address                                      | Notes                                               |
| ------------------ | -------------------------------------------- | --------------------------------------------------- |
| Protocol Token     | `0xddea30fec08416da84424fab9b38130b67478254` | ERC20 implementation deployed and initialized       |
| Protocol Manager   | `0xc9bd53dbf21e477505a4978d5976ac6874a93f46` | Gateway contract, holds ADMIN_ROLE for Activator    |
| Protocol Activator | `0x5c68a908dc0617877aafa3aba8a42e3f5265a013` | Orchestration layer, ADMIN for factories and locker |
| V2 Pool Factory    | `0xd7d8fb219d1e145285995412c4c269e917ddb098` | Creates and manages Uniswap V2 pools                |
| V3 Pool Factory    | `0x8dc2e327b357b0a00cc008f002c12b5158ba8532` | Creates and manages Uniswap V3 positions            |
| Liquidity Locker   | `0x8cbe02fcc9f845c8ee31214e5a73998789eef1c2` | Handles secure V2 liquidity locking via UNCX        |

### 2.2 Protocol Deployment Transaction Hashes
```bash
##### sepolia
✅  [Success] Hash: 0x0598fcdf63ccd491f78b0b5777af77acef378762c7af43a1e78565a32d7bc29d
Contract Address: 0xD7D8FB219D1E145285995412C4C269E917dDB098
Block: 7829542
Paid: 0.001006538993639515 ETH (1368955 gas * 0.735260833 gwei)

##### sepolia
✅  [Success] Hash: 0xc924422d8e2bf01db86e75dcfded3047e19dfbc1f2cc078b4525c43e22ade607
Contract Address: 0x8cbE02fcc9F845C8EE31214E5a73998789eef1C2
Block: 7829542
Paid: 0.000607628375521196 ETH (826412 gas * 0.735260833 gwei)

##### sepolia
✅  [Success] Hash: 0x6df3ffc819af33b623167b7e27a4d14dba1a8fd0cb29482c8de5dfbccb819ff4
Contract Address: 0xddeA30fec08416da84424faB9B38130b67478254
Block: 7829542
Paid: 0.000500678805274682 ETH (680954 gas * 0.735260833 gwei)

##### sepolia
✅  [Success] Hash: 0x9f0561c103ed11a65e8d01d9c92f0ebc6aa2771da21292d7cd7ae085b4b74835
Contract Address: 0x5c68A908DC0617877AafA3ABa8A42E3f5265A013
Block: 7829542
Paid: 0.000769070331883839 ETH (1045983 gas * 0.735260833 gwei)

##### sepolia
✅  [Success] Hash: 0x1067f7c988853945b8279f7c0e81b83d9093fe253ae1823be19ebdce83d6ea06
Block: 7829542
Paid: 0.000057898114294585 ETH (78745 gas * 0.735260833 gwei)

##### sepolia
✅  [Success] Hash: 0xb1986d2bd52ec76a46eb414da4c96a0c7131df4ea69242d986ef8be31972c950
Contract Address: 0x8dc2e327B357b0a00cC008f002c12B5158bA8532
Block: 7829542
Paid: 0.001318080772754943 ETH (1792671 gas * 0.735260833 gwei)

##### sepolia
✅  [Success] Hash: 0x97751260de78cbe4426b6fdadbaccbcc191e2d966a1414c809e9ed7699a489d6
Block: 7829542
Paid: 0.000057853263383772 ETH (78684 gas * 0.735260833 gwei)

##### sepolia
✅  [Success] Hash: 0x98aca713aaba0acd960de900e1dc949b00bae8b1ff8e8b74c342ce6d93a3ada5
Block: 7829542
Paid: 0.000057811353516291 ETH (78627 gas * 0.735260833 gwei)

##### sepolia
✅  [Success] Hash: 0x44951f87870589b90cc24ebf6187eb0df08f2f1705f2d67c44c7865f87400b0a
Contract Address: 0xC9bd53DBF21E477505a4978D5976ac6874A93F46
Block: 7829542
Paid: 0.000798004316184055 ETH (1085335 gas * 0.735260833 gwei)

##### sepolia
✅  [Success] Hash: 0x0d0b3253d83a644ff92a8969c2fe80e5080784c0d86d513f823bc76c3ea9bf7a
Block: 7829542
Paid: 0.000057840028688778 ETH (78666 gas * 0.735260833 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.005231404355141656 ETH (7115032 gas * avg 0.735260833 gwei)
```

### 2.3 Test Pair Token

| Token                | Address                                      | Purpose                          |
| -------------------- | -------------------------------------------- | -------------------------------- |
| Test ERC20 PairToken | `0x78c95fe69f27f5d9a098f8c1c546ebcf530c67ac` | Mock token for audit and testing |

### 2.4 Test Pair Token Deployment Transaction Hash
```bash
##### sepolia
✅  [Success] Hash: 0x21b30a9ea344d21a8bb576ff0dcf7a2ba256e53aebd14ab443e3699270801f98
Contract Address: 0x78C95Fe69F27f5d9A098f8C1c546Ebcf530c67ac
Block: 7825438
Paid: 0.000562877152537385 ETH (492685 gas * 1.142468621 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.000562877152537385 ETH (492685 gas * avg 1.142468621 gwei)
```
### 2.4 LP tokens

| Token                | Address / Identifier                         | 
| -------------------- | -------------------------------------------- | 
| V2 LP ERC20 token    | `0xD97ea525f1b15E7707Ca78A7902086E0DcA1224B` |
| V3 LP NFT token      | `165111`                                     |

## 3. Protocol Activation Details

### 3.1 Activation Transaction Hashes

```bash
##### sepolia
✅  [Success] Hash: 0x1be698e3a4c773763b1fd0beffe5acef7fc7a0f2ee3c16ce6e57b9bb0629adfe
Block: 7829653
Paid: 0.00011042238019188 ETH (51396 gas * 2.14846253 gwei)


##### sepolia
✅  [Success] Hash: 0x2934f551f9b10e82898074973487030f8a3290469a04826aec3008a30721d82d
Block: 7829653
Paid: 0.00011013878313792 ETH (51264 gas * 2.14846253 gwei)


##### sepolia
✅  [Success] Hash: 0x3bbfac23b2040b8087cb9122c5a0c989c0f458c316795ada442bd04c7f820819
Block: 7829653
Paid: 0.00011013878313792 ETH (51264 gas * 2.14846253 gwei)


##### sepolia
✅  [Success] Hash: 0xa153e991dd11d7df1bb9a48ba42e05d803804a16e8afa71309b6e45ab0ef3541
Block: 7829653
Paid: 0.00011042238019188 ETH (51396 gas * 2.14846253 gwei)


##### sepolia
✅  [Success] Hash: 0xaa52a61105e31450e2c12de150c3602129e69d7792b4237c2776b1ce12b48a40
Block: 7829656
Paid: 0.035578621596628682 ETH (16721086 gas * 2.127769787 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.036019743923288282 ETH (16926406 gas * avg 2.144323981 gwei)
```

### 3.2 Activation Scope

The protocol was activated with the following configuration:

```
✅ V2 Pools Created: Yes
✅ V3 Pools Created: Yes
✅ V2 Liquidity Locked: Yes (duration: 365 days)
```

## 4. Contact Information for Audit Queries

For any questions during the audit process:

- **Security Inquiries:** <a href="mailto:web3.security@cordona.tech">web3.security@cordona.tech</a> (Security Lead, vulnerability reports, audit coordination) 🔒
- **Development Support:** <a href="mailto:web3.development@cordona.tech">web3.development@cordona.tech</a> (Technical Lead, implementation details, contract functionality) 💻
- **X(Twitter)**: <a href="https://x.com/foreshadow_xyz?s=21">@foreshadow.xyz</a>

Our security team is available to discuss potential vulnerabilities, clarify security architecture questions, and provide additional context for threat modeling. The development team can assist with questions about implementation details, deployment configuration, and technical specifications. 💡

Feel free to reach out with any questions that arise during your audit process - we're committed to providing timely and thorough responses to support a comprehensive security assessment. 🛡️