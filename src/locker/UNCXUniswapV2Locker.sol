// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title UNCX Uniswap V2 Liquidity Locker Interface
 * @author foreshadow.xyz | cordona.tech
 * @notice Type-safe interface for external UNCX liquidity locking service
 * @dev Defines the integration boundary with UNCX's third-party locker service:
 *
 *      Integration context:
 *      - No official Solidity interface exists for UNCX services
 *      - This interface provides protocol-compatible function signatures
 *      - Used by LiquidityLocker for secure external service interaction
 *
 *      Key capabilities:
 *      - LP token locking with configurable duration
 *      - Fee payment handling (ETH or UNCX token)
 *      - Granular withdrawal rights assignment
 *      - Lock metadata inspection and retrieval
 *
 *      Security considerations:
 *      - External service with independent trust assumptions
 *      - Requires careful error handling in calling contracts
 *      - Token transfer operations potentially revert on failure
 *
 * @custom:security-contact web3.security@cordona.tech
 */
interface UNCXUniswapV2Locker {
    /// @notice UNCX native struct representing a locked liquidity position
    /// @dev Matches UNCX's internal representation for compatibility
    struct TokenLock {
        address lpToken;
        uint256 lockDate;
        uint256 amount;
        uint256 initialAmount;
        uint256 unlockDate;
        uint256 lockID;
        address owner;
        uint16 countryCode;
    }

    /// @notice Locks LP tokens for a specified period with designated withdrawal rights
    /// @dev External Service Integration:
    ///      - Requires prior LP token approval
    ///      - Accepts 0.1 ETH flat fee when fee_in_eth = true
    ///      - Creates irrevocable time lock until unlock date
    ///      - Assigns withdrawal rights to specified address
    ///
    /// @param _lpToken Uniswap V2 LP token address
    /// @param _amount Amount of LP tokens to lock
    /// @param _unlockDate Timestamp when tokens become withdrawable
    /// @param _referral Optional referral address (typically zero address)
    /// @param _fee_in_eth Whether to pay fee in ETH (true) or UNCX tokens (false)
    /// @param _withdrawer Address with rights to withdraw tokens after unlock date
    /// @param _countryCode Regulatory identifier code
    function lockLPToken(
        address _lpToken,
        uint256 _amount,
        uint256 _unlockDate,
        address payable _referral,
        bool _fee_in_eth,
        address payable _withdrawer,
        uint16 _countryCode
    ) external payable;

    /// @notice Retrieves lock details for a specific user, token and index
    /// @dev External Service Behavior:
    ///      - Zero-indexed (first lock at index 0)
    ///      - Reverts if no lock exists at specified index
    ///      - Returns complete lock metadata
    ///
    /// @param _user Lock owner address
    /// @param _lpToken LP token address
    /// @param _index Position index in owner's lock collection (0-based)
    /// @return tokenLock Complete lock metadata
    function getUserLockForTokenAtIndex(address _user, address _lpToken, uint256 _index)
        external
        view
        returns (TokenLock memory tokenLock);
}
