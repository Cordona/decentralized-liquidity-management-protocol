// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Contracts
import {RoleBased} from "src/common/RoleBased.sol";

/**
 * @title Protocol Foundation Layer
 * @author foreshadow.xyz | cordona.tech
 * @notice Core validation and utility functionality used throughout the protocol
 * @dev Implements essential security features:
 *      1. Role-based access control (inherited from RoleBased)
 *      2. Zero-address validation
 *      3. Zero-value protection
 *      4. Standard constants for protocol operations
 *
 *      This contract serves as the foundation for all protocol components,
 *      ensuring consistent validation and error handling.
 *
 * @custom:security-contact web3.security@cordona.tech
 */
abstract contract BaseProtocol is RoleBased {
    // [CONSTANTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    address internal constant ZERO_ADDRESS = address(0);

    uint256 internal constant ZERO_VALUE = 0;

    // [ERRORS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    error Base__ZeroAddress();
    error Base__ZeroValue();

    // [MODIFIERS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    modifier validAddress(address subject) {
        if (subject == ZERO_ADDRESS) {
            revert Base__ZeroAddress();
        }
        _;
    }

    modifier positiveValue(uint256 subject) {
        if (subject == ZERO_VALUE) {
            revert Base__ZeroValue();
        }
        _;
    }
}
