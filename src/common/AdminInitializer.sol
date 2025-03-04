// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Contracts
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {Roles} from "src/common/Roles.sol";

/**
 * @title Admin Role Management System
 * @author foreshadow.xyz | cordona.tech
 * @notice Implements unidirectional admin role transfers with access control
 * @dev Initializes the foundation of the protocol's security model by:
 *      1. Assigning initial admin roles to the deployer
 *      2. Establishing the role hierarchy
 *      3. Providing a secure admin transition mechanism
 *
 *      This contract establishes the starting point for the protocol's
 *      privilege separation architecture, ensuring proper admin initialization
 *      and controlled role transitions.
 *
 * @custom:security-contact web3.security@cordona.tech
 */
abstract contract AdminInitializer is BaseProtocol {
    // [EVENTS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event NewAdmin(address indexed admin);

    // [CONSTRUCTOR] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(Roles.ADMIN_ROLE, msg.sender);
        _setRoleAdmin(Roles.ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
    }

    // [EXTERNAL] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @notice Securely transfers admin privileges using one-way transfer pattern
    /// @dev Implementation flow:
    ///      1. Grants role to new admin
    ///      2. Revokes role from current admin
    ///      3. Emits transfer event for auditability
    /// @param newAdmin Target address for admin privileges
function changeAdmin(address newAdmin) external onlyRole(Roles.ADMIN_ROLE) validAddress(newAdmin) {
        grantRole(Roles.ADMIN_ROLE, newAdmin);
        revokeRole(Roles.ADMIN_ROLE, msg.sender);
        emit NewAdmin(newAdmin);
    }
}
