// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Types
import {ActivationContext} from "src/common/Types.sol";

/**
 * @title Protocol Activator Interface
 * @author foreshadow.xyz | cordona.tech
 * @notice Orchestration layer for protocol pool creation and liquidity operations
 * @dev Defines the security boundary between protocol management and execution:
 *
 *      Security flow:
 *      Manager → Activator → Factories/Locker
 *
 *      This interface serves as the critical middle layer in the protocol's
 *      privilege separation architecture, creating a secure boundary between
 *      administrative commands and execution components.
 *
 * @custom:security-contact web3.security@cordona.tech
 */
interface IProtocolActivator {
    /// @notice Orchestrates protocol pool deployment and liquidity setup
    /// @dev Security & Activation Flow:
    ///      Access Control:
    ///      - Restricted to ProtocolManager only
    ///      - Requires ADMIN_ROLE
    ///      
    ///      Deployment Sequence:
    ///      1. Validation (config, scope, ETH)
    ///      2. V2 Deployment (if enabled)
    ///      3. V2 Locking (if specified)
    ///      4. V3 Deployment (if enabled)
    /// @param context Deployment configuration and factory addresses
    function activate(ActivationContext calldata context) external payable;
}