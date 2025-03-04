// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Contracts
import {AdminInitializer} from "src/common/AdminInitializer.sol";
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {Roles} from "src/common/Roles.sol";

/**
 * @title Protocol Module Initialization System
 * @author foreshadow.xyz | cordona.tech
 * @notice Module initialization with secure role transition
 * @dev Implements single-use initialization pattern with role transition safeguards
 *      that creates the hierarchical security architecture of the protocol.
 *
 *      Key security features:
 *      1. One-time initialization protection
 *      2. Unidirectional admin role transfer
 *      3. Internal admin designation
 *      4. Module state tracking
 *
 *      This contract enables the critical security flow where component roles are
 *      transferred from the external admin (deployer) to the proper internal
 *      administrators, creating the protocol's defense-in-depth architecture.
 *
 * @custom:security-contact web3.security@cordona.tech
 */
abstract contract ModuleInitializer is BaseProtocol, AdminInitializer {
    // [ERRORS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    error ModuleInitializer__AlreadyInitialized();
    error ModuleInitializer__NotInitialized();

    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    bool private s_initialized;

    // [EVENTS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event ModuleInitialized(string indexed module, address indexed internalAdmin);

    // [MODIFIERS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    modifier initialized() {
        if (!s_initialized) {
            revert ModuleInitializer__NotInitialized();
        }
        _;
    }

    // [EXTERNAL] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @notice Performs one-time module initialization with role transition
    /// @dev Creates the hierarchical security architecture by:
    ///      1. Preventing re-initialization attacks
    ///      2. Transferring ADMIN_ROLE to the designated internal admin
    ///      3. Revoking ADMIN_ROLE from the caller (external admin)
    ///      4. Emitting initialization event for auditability
    ///
    ///      This implements the unidirectional privilege flow:
    ///      Deployer → Manager → Activator → Components
    ///
    /// @param module Module identifier for tracking
    /// @param internalAdmin Target admin address
    function initialize(string memory module, address internalAdmin)
        external
        virtual
        onlyRole(Roles.ADMIN_ROLE)
        validAddress(internalAdmin)
    {
        if (s_initialized) {
            revert ModuleInitializer__AlreadyInitialized();
        }

        s_initialized = true;

        grantRole(Roles.ADMIN_ROLE, internalAdmin);
        revokeRole(Roles.ADMIN_ROLE, msg.sender);
        emit ModuleInitialized(module, internalAdmin);
    }

    // [VIEW] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    function isInitialized() public view returns (bool) {
        return s_initialized;
    }
}
