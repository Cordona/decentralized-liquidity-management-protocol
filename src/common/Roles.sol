// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Protocol Role Definitions
 * @author foreshadow.xyz | cordona.tech
 * @notice Core role configuration that defines protocol access boundaries
 * @dev Establishes the two fundamental roles that control the protocol's security:
 *      - ADMIN_ROLE: Operational control for protocol configuration and management
 *      - TOKEN_RESCUER_ROLE: Emergency recovery for stuck tokens
 *
 *      Protocol Access Hierarchy (Post-Deployment):
 *
 *      Deployer
 *         ├── Holds → TOKEN_RESCUER_ROLE   // Emergency Recovery
 *         ├── Initially has ADMIN_ROLE
 *         │   └── Transferred to → ProtocolManager
 *         │
 *         └── ProtocolManager
 *             ├── Becomes ADMIN for → ProtocolActivator
 *             │
 *             └── ProtocolActivator
 *                 ├── Becomes ADMIN for → V2 Factory
 *                 ├── Becomes ADMIN for → V3 Factory
 *                 └── Becomes ADMIN for → Liquidity Locker
 *
 * @custom:security-contact web3.security@cordona.tech
 */
library Roles {
    /// @dev Primary operational role for protocol management
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    /// @dev Emergency role for recovering stuck assets
    bytes32 internal constant TOKEN_RESCUER_ROLE = keccak256("TOKEN_RESCUER_ROLE");
}