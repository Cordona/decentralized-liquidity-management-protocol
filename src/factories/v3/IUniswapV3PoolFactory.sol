// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Interfaces
import {IPoolFactory} from "src/factories/IPoolFactory.sol";

/**
 * @title Uniswap V3 Pool Factory Interface
 * @author foreshadow.xyz | cordona.tech
 * @notice Specialized factory for creating and managing Uniswap V3 concentrated liquidity positions
 * @dev Defines the execution boundary for V3 position operations:
 *
 *      Security flow:
 *      Manager → Activator → V3PoolFactory
 *
 *      This interface represents a restricted execution component that:
 *      - Responds only to the ProtocolActivator (internal admin)
 *      - Creates V3 pools with configurable fee tiers
 *      - Manages full-range liquidity positions via NFTs
 *      - Provides position tracking capabilities
 *
 * @custom:security-contact web3.security@cordona.tech
 */
interface IUniswapV3PoolFactory is IPoolFactory {
    /// @notice Creates a standard Uniswap V3 pool with initial full-range position
    /// @dev Security & Execution Flow:
    ///      Access Control:
    ///      - Restricted to ProtocolActivator only
    ///      - Requires ADMIN_ROLE
    ///      
    ///      Deployment Process:
    ///      1. Pool creation or initialization with sqrtPrice
    ///      2. Token approvals for position manager
    ///      3. Full-range position minting
    ///      4. NFT assignment to recipient
    ///
    /// @param protocolToken Primary token address
    /// @param pairToken Secondary token address
    /// @param liquidityTokensRecipient NFT position recipient
    /// @param protocolTokenLiquidity Amount of protocol tokens for liquidity
    /// @param pairTokenLiquidity Amount of pair tokens for liquidity
    /// @param deadline Maximum execution time frame
    /// @param poolFee Fee tier (500=0.05%, 3000=0.3%, 10000=1%)
    /// @return tokenId Position NFT identifier
    /// @return liquidity Amount of concentrated liquidity
    /// @return fee The pool fee tier
    function createV3Pool(
        address protocolToken,
        address pairToken,
        address liquidityTokensRecipient,
        uint256 protocolTokenLiquidity,
        uint256 pairTokenLiquidity,
        uint256 deadline,
        uint24 poolFee
    ) external returns (uint256 tokenId, uint128 liquidity, uint24 fee);

    /// @notice Creates a Uniswap V3 WETH pool with initial full-range position
    /// @dev Security & Execution Flow:
    ///      Access Control:
    ///      - Restricted to ProtocolActivator only
    ///      - Requires ADMIN_ROLE
    ///      - Payable function that accepts ETH
    ///      
    ///      Deployment Process:
    ///      1. Pool creation or initialization with sqrtPrice
    ///      2. Automatic ETH to WETH conversion
    ///      3. Full-range position minting
    ///      4. NFT assignment to recipient
    ///
    /// @param protocolToken Token to pair with WETH
    /// @param liquidityTokensRecipient NFT position recipient
    /// @param protocolTokenLiquidity Amount of protocol tokens for liquidity
    /// @param deadline Maximum execution time frame
    /// @param poolFee Fee tier (500=0.05%, 3000=0.3%, 10000=1%)
    /// @return tokenId Position NFT identifier
    /// @return liquidity Amount of concentrated liquidity
    /// @return fee The pool fee tier
    function createV3WethPool(
        address protocolToken,
        address liquidityTokensRecipient,
        uint256 protocolTokenLiquidity,
        uint256 deadline,
        uint24 poolFee
    ) external payable returns (uint256 tokenId, uint128 liquidity, uint24 fee);

    /// @notice Retrieves position details for a specific liquidity owner
    /// @dev Provides standardized view access to NFT position information
    /// @param liquidityOwner Address to check position for
    /// @return tokenId Position NFT identifier
    /// @return liquidity Amount of concentrated liquidity
    /// @return fee The pool fee tier
    function getLiquidityDetails(address liquidityOwner)
        external
        view
        returns (uint256 tokenId, uint128 liquidity, uint24 fee);
}