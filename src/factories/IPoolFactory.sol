// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Base Pool Factory Interface
 * @author foreshadow.xyz | cordona.tech
 * @notice Foundation interface for protocol's unified liquidity management
 * @dev Establishes the common error handling pattern for all factory implementations:
 *
 *      Architecture context:
 *      - Serves as the base interface for both V2 and V3 factory implementations
 *      - Creates consistency in error reporting across pool types
 *      - Provides a standardized validation pattern for token balance checks
 *
 *      This interface represents the common foundation layer that:
 *      - Enables polymorphic treatment of different factory types
 *      - Defines shared security validation requirements
 *      - Establishes a consistent error pattern for liquidity operations
 *
 * @custom:security-contact web3.security@cordona.tech
 */
interface IPoolFactory {
    error PoolFactory__InsufficientBalance(address token, uint256 balance, uint256 liquidity);
}
