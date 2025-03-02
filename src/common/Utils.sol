// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Protocol Types & Constants
import {TokenParams} from "src/common/Types.sol";
import {V3Constants} from "src/common/V3Constants.sol";

/**
 * @title Protocol Utility Library
 * @author foreshadow.xyz | cordona.tech
 * @notice Core mathematical and token handling utilities for protocol operations
 * @dev Provides foundational operations for the protocol's technical requirements:
 *
 *      Key capabilities:
 *      - Token scaling with decimal precision
 *      - Address sorting for deterministic pair resolution
 *      - V3-specific mathematical calculations
 *      - Type-safe conversions and validation
 *
 *      Integration context:
 *      - Used by factories for consistent token handling
 *      - Supports V2/V3 pool initialization parameters
 *      - Enforces mathematical safety through validation
 *      - Provides deterministic results for consistency
 *
 * @custom:security-contact web3.security@cordona.tech
 */
library Utils {
    using SafeCast for uint256;

    // [ERRORS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    error Utils__ScalingOverflow(uint256 amount);

    error Utils__IdenticalAddresses();

    // [CONSTANT] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @dev Base for decimal calculations (10)
    uint256 private constant DECIMAL_BASE = 10;

    /// @dev Scaling factor for percentage calculations (100)
    uint256 private constant PERCENTAGE_SCALE = 100;

    /// @notice Converts ETH amounts from wei to whole units for consistent scaling
    /// @dev Normalization function used in two critical paths:
    ///      1. ETH validation during activation
    ///      2. Liquidity provision in V3 pools
    ///
    ///      The function ensures ETH amounts align with other token scaling
    ///      operations by removing the 18 decimal places from wei values.
    ///
    /// @param amount Raw amount in wei (typically from msg.value)
    /// @return Normalized ETH value as a whole number
    function descaleEth(uint256 amount) internal pure returns (uint256) {
        return amount / 1 ether;
    }

    /// @notice Scales token amounts based on their decimal precision
    /// @dev Security-focused scaling with overflow protection:
    ///      - Dynamically reads token decimals from contract
    ///      - Validates scaling operation against overflow thresholds
    ///      - Reverts with detailed error information on overflow
    ///
    ///      This function ensures all token operations use correct decimal
    ///      scaling regardless of the token's decimal configuration.
    ///
    /// @param amount Raw token amount (in whole units)
    /// @param token Token contract address to read decimals from
    /// @return Precisely scaled amount with decimal adjustment
    function safeScale(uint256 amount, address token) internal view returns (uint256) {
        uint8 decimals = IERC20Metadata(token).decimals();
        uint256 scalingThreshold = type(uint256).max / (DECIMAL_BASE ** decimals);

        if (amount > scalingThreshold) {
            revert Utils__ScalingOverflow(amount);
        }

        return amount * DECIMAL_BASE ** decimals;
    }

    /// @notice Deterministically sorts two token addresses
    /// @dev Critical for consistent pair identification:
    ///      - Ensures token0 is always the numerically smaller address
    ///      - Prevents duplicate pairs with reversed token order
    ///      - Validates against identical token addresses
    ///
    ///      This ensures deterministic behavior when creating or querying
    ///      pools across the protocol.
    ///
    /// @param first First token address
    /// @param second Second token address
    /// @return token0 Numerically smaller address
    /// @return token1 Numerically larger address
    function sortTokenAddresses(address first, address second) internal pure returns (address token0, address token1) {
        if (first == second) revert Utils__IdenticalAddresses();

        token0 = first < second ? first : second;
        token1 = first < second ? second : first;
    }

    /// @notice Creates sorted TokenParams with properly scaled liquidity values
    /// @dev V3 pool preparation utility:
    ///      - Scales both token amounts according to their decimals
    ///      - Sorts tokens by address (required by Uniswap V3)
    ///      - Encapsulates both operations in a single consistent function
    ///
    ///      Used specifically by V3 factory to prepare parameters for
    ///      position creation.
    ///
    /// @param tokenA First token address
    /// @param tokenALiquidity First token liquidity amount
    /// @param tokenB Second token address
    /// @param tokenBLiquidity Second token liquidity amount
    /// @return token0 Sorted parameters for token0 (smaller address)
    /// @return token1 Sorted parameters for token1 (larger address)
    function buildTokenParams(address tokenA, uint256 tokenALiquidity, address tokenB, uint256 tokenBLiquidity)
        internal
        view
        returns (TokenParams memory token0, TokenParams memory token1)
    {
        uint256 scaledTokenALiquidity = safeScale(tokenALiquidity, tokenA);
        uint256 scaledTokenBLiquidity = safeScale(tokenBLiquidity, tokenB);

        if (tokenA < tokenB) {
            token0 = TokenParams({addr: tokenA, scaledLiquidity: scaledTokenALiquidity});
            token1 = TokenParams({addr: tokenB, scaledLiquidity: scaledTokenBLiquidity});
        } else {
            token0 = TokenParams({addr: tokenB, scaledLiquidity: scaledTokenBLiquidity});
            token1 = TokenParams({addr: tokenA, scaledLiquidity: scaledTokenALiquidity});
        }
    }

    /// @notice Calculates the square root price for V3 pool initialization
    /// @dev Mathematically precise V3 price calculation:
    ///      - Takes the ratio of token amounts (token1/token0)
    ///      - Converts to Q64.96 fixed-point representation
    ///      - Takes square root to derive sqrtPriceX96
    ///      - Safely casts to uint160 for V3 compatibility
    ///
    ///      This function ensures price calculations remain accurate
    ///      regardless of input token quantities.
    ///
    /// @param token0ScaledLiquidity Scaled amount of token0
    /// @param token1ScaledLiquidity Scaled amount of token1
    /// @return Sqrt price in Q64.96 format for V3 pool initialization
    function sqrtX96Price(uint256 token0ScaledLiquidity, uint256 token1ScaledLiquidity)
        internal
        pure
        returns (uint160)
    {
        uint256 ratioX96 = (token1ScaledLiquidity * (1 << 96)) / token0ScaledLiquidity;
        uint256 sqrtRatioX96 = Math.sqrt(ratioX96) * (1 << 48);
        return sqrtRatioX96.toUint160();
    }

    /// @notice Determines tick spacing for a given V3 fee tier
    /// @dev Fee-to-spacing conversion for V3 positions:
    ///      - Maps each supported fee tier to its standardized tick spacing
    ///      - Ensures positions comply with Uniswap V3 tick spacing rules
    ///      - Used during pool initialization and position minting
    ///
    ///      Supported mappings:
    ///      - 0.05% fee → 10 tick spacing
    ///      - 0.30% fee → 60 tick spacing
    ///      - 1.00% fee → 200 tick spacing
    ///
    /// @param fee The fee tier (500, 3000, or 10000)
    /// @return tickSpacing The corresponding tick spacing value
    function computeTickSpacing(uint24 fee) internal pure returns (int24 tickSpacing) {
        if (fee == V3Constants.FEE_LOW) return V3Constants.TICK_SPACING_LOW;
        if (fee == V3Constants.FEE_MEDIUM) return V3Constants.TICK_SPACING_MEDIUM;
        if (fee == V3Constants.FEE_HIGH) return V3Constants.TICK_SPACING_HIGH;
    }

    /// @notice Aligns a tick value to the nearest valid tick spacing
    /// @dev Tick validation and alignment utility:
    ///      - Rounds tick to the nearest valid tick according to spacing
    ///      - Enforces MIN_TICK and MAX_TICK boundaries
    ///      - Ensures ticks are properly spaced for position creation
    ///
    ///      This function is essential for full-range position creation
    ///      in our V3 factory implementation.
    ///
    /// @param tick Raw tick value to align
    /// @param tickSpacing Tick spacing for the fee tier
    /// @return Properly aligned tick value
    function roundToTickSpacing(int24 tick, int24 tickSpacing) internal pure returns (int24) {
        int24 rounded = tick - (tick % tickSpacing);
        if (rounded < V3Constants.MIN_TICK) return V3Constants.MIN_TICK;
        if (rounded > V3Constants.MAX_TICK) return V3Constants.MAX_TICK;
        return rounded;
    }
}
