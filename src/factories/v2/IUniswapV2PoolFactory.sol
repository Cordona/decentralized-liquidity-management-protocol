// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Interfaces
import {IPoolFactory} from "src/factories/IPoolFactory.sol";

/**
 * @title Uniswap V2 Pool Factory Interface
 * @author foreshadow.xyz | cordona.tech
 * @notice Specialized factory for creating and managing Uniswap V2 liquidity pools
 * @dev Defines the execution boundary for V2 pool operations:
 *
 *      Security flow:
 *      Manager → Activator → V2PoolFactory
 *
 *      This interface represents a restricted execution component that:
 *      - Responds only to the ProtocolActivator (internal admin)
 *      - Creates standardized V2 pools following protocol parameters
 *      - Provides liquidity tracking capabilities for deployed pools
 *
 * @custom:security-contact web3.security@cordona.tech
 */
interface IUniswapV2PoolFactory is IPoolFactory {
    /// @notice Creates a standard Uniswap V2 ERC20/ERC20 pool with initial liquidity
    /// @dev Security & Execution Flow:
    ///      Access Control:
    ///      - Restricted to ProtocolActivator only
    ///      - Requires ADMIN_ROLE
    ///
    ///      Deployment Process:
    ///      1. Pool creation or discovery (if exists)
    ///      2. Token approvals for router
    ///      3. Initial liquidity addition
    ///      4. LP token assignment to recipient
    ///
    /// @param protocolToken Primary token address
    /// @param pairToken Secondary token address
    /// @param liquidityTokensRecipient LP token recipient
    /// @param protocolTokenLiquidity Amount of protocol tokens for liquidity
    /// @param pairTokenLiquidity Amount of pair tokens for liquidity
    /// @param deadline Maximum execution time frame
    /// @return liquidityToken Address of the LP token contract
    /// @return liquidity Amount of LP tokens minted
    function createV2Pool(
        address protocolToken,
        address pairToken,
        address liquidityTokensRecipient,
        uint256 protocolTokenLiquidity,
        uint256 pairTokenLiquidity,
        uint256 deadline
    ) external returns (address liquidityToken, uint256 liquidity);

    /// @notice Creates a Uniswap V2 pool with ETH/WETH and provides initial liquidity
    /// @dev Security & Execution Flow:
    ///      Access Control:
    ///      - Restricted to ProtocolActivator only
    ///      - Requires ADMIN_ROLE
    ///      - Payable function that accepts ETH
    ///
    ///      Deployment Process:
    ///      1. Pool creation or discovery (if exists)
    ///      2. Automatic ETH to WETH conversion
    ///      3. Initial liquidity addition
    ///      4. LP token assignment to recipient
    ///
    /// @param protocolToken Token to pair with WETH
    /// @param liquidityTokensRecipient LP token recipient
    /// @param protocolTokenLiquidity Amount of protocol tokens for liquidity
    /// @param deadline Maximum execution time frame
    /// @return liquidityToken Address of the LP token contract
    /// @return liquidity Amount of LP tokens minted
    function createV2WethPool(
        address protocolToken,
        address liquidityTokensRecipient,
        uint256 protocolTokenLiquidity,
        uint256 deadline
    ) external payable returns (address liquidityToken, uint256 liquidity);

    /// @notice Retrieves liquidity details for a specific token pair and owner
    /// @dev Provides standardized view access to LP token information
    /// @param tokenA First token in the pair
    /// @param tokenB Second token in the pair
    /// @param liquidityOwner Address to check LP balance for
    /// @return liquidityToken Address of the LP token contract
    /// @return liquidity Balance of LP tokens for the owner
    function getLiquidityDetails(address tokenA, address tokenB, address liquidityOwner)
        external
        view
        returns (address liquidityToken, uint256 liquidity);
}
