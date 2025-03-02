// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Uniswap V3 Position Manager Interface
 * @author foreshadow.xyz | cordona.tech
 * @notice Compatibility layer for Uniswap V3 position management operations
 * @dev Defines the interaction boundary with Uniswap V3's NFT-based position system:
 *
 *      This interface provides a Solidity 0.8.28 compatible wrapper around
 *      Uniswap V3's position management functionality, enabling the protocol
 *      to create and monitor concentrated liquidity positions.
 *
 *      Key capabilities:
 *      - Pool creation and initialization with precise price settings
 *      - Full-range position management (MIN_TICK to MAX_TICK)
 *      - NFT-based position tracking and enumeration
 *      - Multi-fee tier support (0.05%, 0.3%, 1%)
 *
 *      Integration context:
 *      - Used by UniswapV3PoolFactory for position creation
 *      - Maintains compatibility with Uniswap's original interfaces
 *      - Provides deterministic position access patterns
 *
 * @custom:security-contact web3.security@cordona.tech
 */
interface IUniswapV3PositionManager {
    /// @notice Native Uniswap V3 Parameters struct for creating a new V3 liquidity position
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    /// @notice Creates or initializes a V3 pool with specified price
    /// @param token0 First token address (must be sorted)
    /// @param token1 Second token address (must be sorted)
    /// @param fee Fee tier for the pool
    /// @param sqrtPriceX96 Initial price in sqrt price format (Q64.96)
    /// @return pool Address of the created or existing pool
    function createAndInitializePoolIfNecessary(address token0, address token1, uint24 fee, uint160 sqrtPriceX96)
        external
        payable
        returns (address pool);

    /// @notice Creates a new liquidity position and mints an NFT
    /// @param params Complete position configuration
    /// @return tokenId Unique NFT identifier for the position
    /// @return liquidity Amount of concentrated liquidity
    /// @return amount0 Actual amount of token0 used
    /// @return amount1 Actual amount of token1 used
    function mint(MintParams calldata params)
        external
        payable
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

    /// @notice Returns the number of positions owned by an address
    /// @param owner Position owner to query
    /// @return balance Number of positions owned
    function balanceOf(address owner) external view returns (uint256 balance);

    /// @notice Gets a position ID by its index in the owner's collection
    /// @param owner Position owner address
    /// @param index Zero-based index in the owner's collection
    /// @return tokenId Position identifier
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /// @notice Retrieves detailed position information by token ID
    /// @param tokenId Position NFT identifier
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
}
