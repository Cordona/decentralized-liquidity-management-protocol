// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Uniswap V3 Protocol Constants
 * @author foreshadow.xyz | cordona.tech
 * @notice Core constants for V3 pool creation and position management
 * @dev Defines standardized values for fees, ticks, and position tracking
 * @custom:security-contact web3.security@cordona.tech
 */
library V3Constants {
    /// @dev Position NFT index for initial liquidity
    ///      Always 0 for protocol-created pools as we're the first LP
    uint256 internal constant INITIAL_MINTED_POSITION = 0;

    /// @dev Fee tiers in hundredths of a bip (0.01%)
    ///      LOW    = 0.05% (50/10000)
    ///      MEDIUM = 0.30% (300/10000)
    ///      HIGH   = 1.00% (1000/10000)
    uint24 internal constant FEE_LOW = 500;
    uint24 internal constant FEE_MEDIUM = 3000;
    uint24 internal constant FEE_HIGH = 1e4;

    /// @dev Tick spacing per fee tier (larger fees = wider spacing)
    int24 internal constant TICK_SPACING_LOW = 10; // 0.05% fee
    int24 internal constant TICK_SPACING_MEDIUM = 60; // 0.30% fee
    int24 internal constant TICK_SPACING_HIGH = 200; // 1.00% fee

    /// @dev Price range boundaries (ln(price) * 2^23)
    ///      Used for full-range position creation
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = 887272;
}
