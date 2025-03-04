// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Protocol Interfaces
import {IUniswapV3PositionManager} from "src/factories/v3/IUniswapV3PositionManager.sol";
import {IUniswapV3PoolFactory} from "src/factories/v3/IUniswapV3PoolFactory.sol";
import {IWETH9} from "src/token/IWETH9.sol";

// Protocol Contracts, Types and Utils
import {ModuleInitializer} from "src/initializer/ModuleInitializer.sol";
import {TokenRescuer} from "src/rescuer/TokenRescuer.sol";
import {Utils} from "src/common/Utils.sol";
import {Roles} from "src/common/Roles.sol";
import {TokenParams} from "src/common/Types.sol";
import {V3Constants} from "src/common/V3Constants.sol";

/**
 * @title Uniswap V3 Pool Factory Implementation
 * @author foreshadow.xyz | cordona.tech
 * @notice Secure factory for managing Uniswap V3 concentrated liquidity positions
 * @dev Implements a protected execution component in the protocol's security architecture,
 *      serving as the bridge between the protocol and Uniswap V3 infrastructure.
 *
 *      Security architecture:
 *      - Operates exclusively under ProtocolActivator's authorization
 *      - Implements ModuleInitializer for secure role transition
 *      - Includes TokenRescuer for emergency fund recovery
 *      - Enforces strict address validation and token scaling
 *
 *      Technical integration:
 *      1. V3 Position Management
 *         - Direct interface with Uniswap V3 Position Manager
 *         - Full-range liquidity position creation (MIN_TICK to MAX_TICK)
 *         - Deterministic price calculation based on token quantities
 *         - NFT-based position tracking
 *
 *      2. Concentrated Liquidity Handling
 *         - Configurable fee tier support (0.05%, 0.3%, 1%)
 *         - Tick spacing calculations for different fee tiers
 *         - WETH wrapping for ETH-based pools
 *         - Token sorting and parameter normalization
 *
 * @custom:security-contact web3.security@cordona.tech
 */
contract UniswapV3PoolFactory is IUniswapV3PoolFactory, ModuleInitializer, TokenRescuer {
    using Utils for uint256;
    using SafeERC20 for IERC20;

    /// @dev Used for Uniswap pool creation operations
    /// @notice Zero slippage is safe only during initial pool creation
    uint256 internal constant NO_SLIPPAGE = 0;

    // [IMMUTABLE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    IUniswapV3PositionManager public immutable i_positionManager;
    IWETH9 public immutable i_weth;

    // [CONSTRUCTOR] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    constructor(address positionManager, address weth) validAddress(positionManager) validAddress(weth) {
        i_positionManager = IUniswapV3PositionManager(positionManager);
        i_weth = IWETH9(weth);
    }

    // [EVENTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event V3PoolCreated(
        address indexed protocolToken, address indexed pairToken, address indexed liquidityTokenRecipient
    );

    // [EXTERNAL] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @inheritdoc IUniswapV3PoolFactory
    function createV3Pool(
        address protocolToken,
        address pairToken,
        address liquidityTokensRecipient,
        uint256 protocolTokenLiquidity,
        uint256 pairTokenLiquidity,
        uint256 deadline,
        uint24 poolFee
    )
        external
        override
        onlyRole(Roles.ADMIN_ROLE)
        initialized
        returns (uint256 tokenId, uint128 liquidity, uint24 fee)
    {
        address positionManagerAddr = address(i_positionManager);

        (TokenParams memory token0, TokenParams memory token1) =
            Utils.buildTokenParams(protocolToken, protocolTokenLiquidity, pairToken, pairTokenLiquidity);

        uint256 token0Balance = IERC20(token0.addr).balanceOf(address(this));
        uint256 token1Balance = IERC20(token1.addr).balanceOf(address(this));

        if (token0Balance < token0.scaledLiquidity) {
            revert PoolFactory__InsufficientBalance(token0.addr, token0Balance, token0.scaledLiquidity);
        }
        if (token1Balance < token1.scaledLiquidity) {
            revert PoolFactory__InsufficientBalance(token1.addr, token1Balance, token1.scaledLiquidity);
        }

        uint160 price = Utils.sqrtX96Price(token0.scaledLiquidity, token1.scaledLiquidity);

        emit V3PoolCreated(address(protocolToken), address(pairToken), address(liquidityTokensRecipient));

        i_positionManager.createAndInitializePoolIfNecessary(token0.addr, token1.addr, poolFee, price);

        IERC20(token0.addr).forceApprove(positionManagerAddr, token0.scaledLiquidity);
        IERC20(token1.addr).forceApprove(positionManagerAddr, token1.scaledLiquidity);

        int24 tickSpacing = Utils.computeTickSpacing(poolFee);

        int24 tickLower = Utils.roundToTickSpacing(V3Constants.MIN_TICK, tickSpacing);
        int24 tickUpper = Utils.roundToTickSpacing(V3Constants.MAX_TICK, tickSpacing);

        IUniswapV3PositionManager.MintParams memory params = IUniswapV3PositionManager.MintParams({
            token0: token0.addr,
            token1: token1.addr,
            fee: poolFee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: token0.scaledLiquidity,
            amount1Desired: token1.scaledLiquidity,
            amount0Min: NO_SLIPPAGE,
            amount1Min: NO_SLIPPAGE,
            recipient: liquidityTokensRecipient,
            deadline: block.timestamp + deadline
        });

        i_positionManager.mint(params);

        return _getLiquidityDetails(liquidityTokensRecipient);
    }

    /// @inheritdoc IUniswapV3PoolFactory
    function createV3WethPool(
        address protocolToken,
        address liquidityTokensRecipient,
        uint256 protocolTokenLiquidity,
        uint256 deadline,
        uint24 poolFee
    )
        external
        payable
        override
        onlyRole(Roles.ADMIN_ROLE)
        initialized
        returns (uint256 tokenId, uint128 liquidity, uint24 fee)
    {
        address positionManagerAddr = address(i_positionManager);

        uint256 scaledTokenLiquidity = protocolTokenLiquidity.safeScale(protocolToken);
        uint256 tokenBalance = IERC20(protocolToken).balanceOf(address(this));

        if (tokenBalance < scaledTokenLiquidity) {
            revert PoolFactory__InsufficientBalance(protocolToken, tokenBalance, scaledTokenLiquidity);
        }

        (TokenParams memory token0, TokenParams memory token1) =
            Utils.buildTokenParams(protocolToken, protocolTokenLiquidity, address(i_weth), msg.value.descaleEth());

        uint160 price = Utils.sqrtX96Price(token0.scaledLiquidity, token1.scaledLiquidity);

        emit V3PoolCreated(address(protocolToken), address(i_weth), address(liquidityTokensRecipient));

        i_positionManager.createAndInitializePoolIfNecessary(token0.addr, token1.addr, poolFee, price);

        i_weth.deposit{value: msg.value}();

        IERC20(token0.addr).forceApprove(positionManagerAddr, token0.scaledLiquidity);
        IERC20(token1.addr).forceApprove(positionManagerAddr, token1.scaledLiquidity);

        int24 tickSpacing = Utils.computeTickSpacing(poolFee);

        int24 tickLower = Utils.roundToTickSpacing(V3Constants.MIN_TICK, tickSpacing);
        int24 tickUpper = Utils.roundToTickSpacing(V3Constants.MAX_TICK, tickSpacing);

        IUniswapV3PositionManager.MintParams memory params = IUniswapV3PositionManager.MintParams({
            token0: token0.addr,
            token1: token1.addr,
            fee: poolFee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: token0.scaledLiquidity,
            amount1Desired: token1.scaledLiquidity,
            amount0Min: NO_SLIPPAGE,
            amount1Min: NO_SLIPPAGE,
            recipient: liquidityTokensRecipient,
            deadline: block.timestamp + deadline
        });

        i_positionManager.mint(params);

        return _getLiquidityDetails(liquidityTokensRecipient);
    }

    /// @inheritdoc IUniswapV3PoolFactory
    function getLiquidityDetails(address liquidityOwner)
        external
        view
        returns (uint256 tokenId, uint128 liquidity, uint24 fee)
    {
        return _getLiquidityDetails(liquidityOwner);
    }

    // [PRIVATE] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    function _getLiquidityDetails(address liquidityOwner)
        private
        view
        returns (uint256 tokenId, uint128 liquidity, uint24 fee)
    {
        if (i_positionManager.balanceOf(liquidityOwner) <= ZERO_VALUE) {
            return (uint256(ZERO_VALUE), uint128(ZERO_VALUE), uint24(ZERO_VALUE));
        }

        tokenId = i_positionManager.tokenOfOwnerByIndex(liquidityOwner, V3Constants.INITIAL_MINTED_POSITION);

        (,,,, fee,,, liquidity,,,,) = i_positionManager.positions(tokenId);
    }
}
