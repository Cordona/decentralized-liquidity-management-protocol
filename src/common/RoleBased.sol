// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Role-Based Access Control Foundation
 * @author foreshadow.xyz | cordona.tech
 * @notice Extends OpenZeppelin's AccessControl with enhanced role verification capabilities
 * @dev Modifies the standard hasRole() functionality to return:
 *      - The original role identifier when authorized (preserving role uniqueness)
 *      - bytes32(0) when unauthorized (enabling explicit role absence checking)
 *
 *      This enhancement enables more granular role checking throughout the protocol
 *      and provides a cleaner interface for conditional role validation.
 *
 * @custom:security-contact web3.security@cordona.tech
 */
abstract contract RoleBased is AccessControl {
    /// @notice Enhanced role verification that returns the role identifier on success
    /// @dev Improves the base AccessControl implementation for protocol-specific checks
    /// @param role The role identifier to verify
    /// @return bytes32 The original role identifier if authorized, bytes32(0) if unauthorized
    function hasRole(bytes32 role) external view virtual override returns (bytes32) {
        return hasRole(role, msg.sender) ? role : bytes32(0);
    }
}
