// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Liquidity Locker Interface
 * @author foreshadow.xyz | cordona.tech
 * @notice Security component for ensuring locked liquidity in Uniswap V2 pools
 * @dev Defines the execution boundary for liquidity locking operations:
 *
 *      Security flow:
 *      Manager → Activator → LiquidityLocker → External Locker Service
 *
 *      This interface represents a restricted execution component that:
 *      - Responds only to the ProtocolActivator (internal admin)
 *      - Provides standardized access to third-party locking services
 *      - Enforces minimum lock duration requirements
 *      - Creates a secure boundary around external locker integration
 *
 * @custom:security-contact web3.security@cordona.tech
 */
interface ILiquidityLocker {
    error LiquidityLocker__InvalidLockDuration(uint256 invalid, uint256 expected);

    /// @notice Locks V2 liquidity tokens for a specified period with secure withdrawal rights
    /// @dev Security & Execution Flow:
    ///      Access Control:
    ///      - Restricted to ProtocolActivator only
    ///      - Requires ADMIN_ROLE
    ///      - Payable function that accepts locking fee
    ///
    ///      Locking Process:
    ///      1. LP token approval to external locker
    ///      2. Lock registration with external service
    ///      3. Withdrawal rights assignment to specified recipient
    ///
    /// @param liquidityToken LP token contract address
    /// @param liquidity Amount of LP tokens to lock
    /// @param withdrawer Address with rights to withdraw tokens after unlock date
    function lockV2Liquidity(address liquidityToken, uint256 liquidity, address withdrawer) external payable;

    /// @notice Retrieves details of a liquidity lock for a given LP token and owner
    /// @dev External Locker Integration:
    ///      - Uses defensive try/catch pattern for external service calls
    ///      - Returns standardized zero values with NO_LOCK_ID when no lock exists
    ///      - Handles external service revert cases gracefully
    ///
    ///      Lock ID Special Values:
    ///      - Valid locks return their actual lockID (typically starting from 0)
    ///      - Non-existent locks return type(uint256).max
    ///
    /// @param lockOwner The address of the lock owner
    /// @param liquidityToken The LP token address
    /// @return lockDate The timestamp when the lock was created
    /// @return amount The current locked token amount
    /// @return initialAmount The initial amount that was locked
    /// @return unlockDate The timestamp when tokens can be withdrawn
    /// @return lockId The unique identifier of the lock (or type(uint256).max if no lock)
    /// @return owner The address with ownership rights to the lock
    function getV2LiquidityLockDetails(address lockOwner, address liquidityToken)
        external
        view
        returns (
            uint256 lockDate,
            uint256 amount,
            uint256 initialAmount,
            uint256 unlockDate,
            uint256 lockId,
            address owner
        );
}
