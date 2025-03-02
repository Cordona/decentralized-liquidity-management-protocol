// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @notice Core configuration for pool creation and protocol activation
 * @dev Passed to ProtocolManager.activate() to initiate pool deployment
 */
struct PoolConfig {
    address liquidityTokensRecipient;
    address token;
    address pair;
    address weth;
    uint24 fee;
    uint256 deadline;
    uint256 tokenLiquidity;
    uint256 pairLiquidity;
    uint256 wethLiquidity;
}

/**
 * @notice Controls which protocol features to activate
 * @dev Passed to ProtocolManager.activate() to initiate pool deployment
 */
struct ActivationScope {
    bool createV2Pools;
    bool createV3Pools;
    bool lockV2Liquidity;
}

/**
 * @dev Internal struct that encapsulates activation parameters and protocol contract addresses
 */
struct ActivationContext {
    PoolConfig config;
    ActivationScope scope;
    address v2Factory;
    address v3Factory;
    address liquidityLocker;
}

/**
 * @dev Internal struct for token address and its scaled liquidity amount
 */
struct TokenParams {
    address addr;
    uint256 scaledLiquidity;
}
