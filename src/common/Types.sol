// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @notice Wrapper struct for deployment addresses
 * @dev Used in the ActivateProtocol script
 */
struct ProtocolDeployments {
    address manager;
    address v2factory;
    address v3factory;
}

/**
 * @notice Core configuration for pool creation and protocol activation
 * @dev Passed to ProtocolManager.activate() to initiate pool deployment
 */
struct PoolConfig {
    address liquidityTokensRecipient;
    address protocolToken;
    address pairToken;
    address weth;
    uint24 v3PoolFee;
    uint256 liquidityLockerEthFee;
    uint256 deadline;
    uint256 protocolTokenLiquidity;
    uint256 pairTokenLiquidity;
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
