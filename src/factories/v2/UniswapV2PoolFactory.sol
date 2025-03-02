// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IUniswapV2Factory} from "@uniswap/v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/interfaces/IUniswapV2Router02.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Protocol Interfaces
import {IUniswapV2PoolFactory} from "src/factories/v2/IUniswapV2PoolFactory.sol";

// Protocol Contracts & Utils
import {ModuleInitializer} from "src/initializer/ModuleInitializer.sol";
import {TokenRescuer} from "src/rescuer/TokenRescuer.sol";
import {Utils} from "src/common/Utils.sol";
import {Roles} from "src/common/Roles.sol";

/**
 * @title Uniswap V2 Pool Factory Implementation
 * @author foreshadow.xyz | cordona.tech
 * @notice Secure factory for creating and tracking Uniswap V2 liquidity pools
 * @dev Implements a protected execution component in the protocol's security architecture,
 *      serving as the bridge between the protocol and Uniswap V2 infrastructure.
 *
 *      Security architecture:
 *      - Operates exclusively under ProtocolActivator's authorization
 *      - Implements ModuleInitializer for secure role transition
 *      - Includes TokenRescuer for emergency fund recovery
 *      - Enforces strict address validation and token scaling
 *
 *      Technical integration:
 *      1. V2 Contract Integration
 *         - Direct interface with Uniswap V2 Router and Factory
 *         - Safe token handling through OpenZeppelin's SafeERC20
 *         - Delegated liquidity provision through Uniswap's standard patterns
 *
 *      2. Security Considerations
 *         - Enforces zero slippage for initial pool creation
 *         - Scales token amounts appropriately for different decimals
 *         - Validates token availability before operations
 *         - Returns detailed liquidity information for verification
 *
 * @custom:security-contact web3.security@cordona.tech
 */
contract UniswapV2PoolFactory is IUniswapV2PoolFactory, ModuleInitializer, TokenRescuer {
    using Utils for uint256;
    using SafeERC20 for IERC20;

    // [CONSTANTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @dev Used for Uniswap pool creation operations
    /// @notice Zero slippage is safe only during initial pool creation
    uint256 internal constant NO_SLIPPAGE = 0;

    // [IMMUTABLE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    IUniswapV2Factory public immutable i_v2Factory;
    IUniswapV2Router02 public immutable i_v2Router;
    address public immutable i_wethAddr;

    // [EVENTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event V2PoolCreated(
        address indexed protocolToken, address indexed pairToken, address indexed liquidityTokenRecipient
    );

    // [CONSTRUCTOR] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    constructor(address v2Factory, address v2router, address weth)
        validAddress(v2Factory)
        validAddress(v2router)
        validAddress(weth)
    {
        i_v2Router = IUniswapV2Router02(v2router);
        i_v2Factory = IUniswapV2Factory(v2Factory);
        i_wethAddr = weth;
    }

    // [EXTERNAL] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @inheritdoc IUniswapV2PoolFactory
    function createV2Pool(
        address protocolToken,
        address pairToken,
        address liquidityTokensRecipient,
        uint256 protocolTokenLiquidity,
        uint256 pairTokenLiquidity,
        uint256 deadline
    ) external override onlyRole(Roles.ADMIN_ROLE) initialized returns (address liquidityToken, uint256 liquidity) {
        address routerAddr = address(i_v2Router);

        uint256 scaledProtocolTokenLiquidity = protocolTokenLiquidity.safeScale(protocolToken);
        uint256 scaledPairTokenLiquidity = pairTokenLiquidity.safeScale(pairToken);

        uint256 protocolTokenBalance = IERC20(protocolToken).balanceOf(address(this));
        uint256 pairTokenBalance = IERC20(pairToken).balanceOf(address(this));

        if (protocolTokenBalance < scaledProtocolTokenLiquidity) {
            revert PoolFactory__InsufficientBalance(protocolToken, protocolTokenBalance, scaledProtocolTokenLiquidity);
        }

        if (pairTokenBalance < scaledPairTokenLiquidity) {
            revert PoolFactory__InsufficientBalance(pairToken, pairTokenBalance, scaledPairTokenLiquidity);
        }

        IERC20(protocolToken).forceApprove(routerAddr, scaledProtocolTokenLiquidity);
        IERC20(pairToken).forceApprove(routerAddr, scaledPairTokenLiquidity);

        emit V2PoolCreated(protocolToken, pairToken, liquidityTokensRecipient);

        i_v2Router.addLiquidity(
            protocolToken,
            pairToken,
            scaledProtocolTokenLiquidity,
            scaledPairTokenLiquidity,
            NO_SLIPPAGE,
            NO_SLIPPAGE,
            liquidityTokensRecipient,
            block.timestamp + deadline
        );

        return _getLiquidityDetails(protocolToken, pairToken, liquidityTokensRecipient);
    }

    /// @inheritdoc IUniswapV2PoolFactory
    function createV2WethPool(
        address protocolToken,
        address liquidityTokensRecipient,
        uint256 protocolTokenLiquidity,
        uint256 deadline
    )
        external
        payable
        override
        onlyRole(Roles.ADMIN_ROLE)
        initialized
        returns (address liquidityToken, uint256 liquidity)
    {
        address routerAddr = address(i_v2Router);

        uint256 scaledProtocolTokenLiquidity = protocolTokenLiquidity.safeScale(protocolToken);
        uint256 protocolTokenBalance = IERC20(protocolToken).balanceOf(address(this));

        if (protocolTokenBalance < scaledProtocolTokenLiquidity) {
            revert PoolFactory__InsufficientBalance(protocolToken, protocolTokenBalance, scaledProtocolTokenLiquidity);
        }

        IERC20(protocolToken).forceApprove(routerAddr, scaledProtocolTokenLiquidity);

        emit V2PoolCreated(protocolToken, i_wethAddr, liquidityTokensRecipient);

        i_v2Router.addLiquidityETH{value: msg.value}(
            protocolToken,
            scaledProtocolTokenLiquidity,
            NO_SLIPPAGE,
            NO_SLIPPAGE,
            liquidityTokensRecipient,
            block.timestamp + deadline
        );

        return _getLiquidityDetails(protocolToken, i_wethAddr, liquidityTokensRecipient);
    }

    /// @inheritdoc IUniswapV2PoolFactory
    function getLiquidityDetails(address tokenA, address tokenB, address liquidityOwner)
        external
        view
        returns (address liquidityToken, uint256 liquidity)
    {
        return _getLiquidityDetails(tokenA, tokenB, liquidityOwner);
    }

    // [PRIVATE] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    function _getLiquidityDetails(address tokenA, address tokenB, address liquidityOwner)
        private
        view
        returns (address liquidityToken, uint256 liquidity)
    {
        (address token0, address token1) = Utils.sortTokenAddresses(tokenA, tokenB);
        liquidityToken = i_v2Factory.getPair(token0, token1);

        if (liquidityToken == ZERO_ADDRESS) {
            return (ZERO_ADDRESS, ZERO_VALUE);
        }

        liquidity = IERC20(liquidityToken).balanceOf(liquidityOwner);
    }
}
