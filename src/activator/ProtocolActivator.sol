// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Protocol Interfaces
import {IProtocolActivator} from "src/activator/IProtocolActivator.sol";
import {IUniswapV2PoolFactory} from "src/factories/v2/IUniswapV2PoolFactory.sol";
import {IUniswapV3PoolFactory} from "src/factories/v3/IUniswapV3PoolFactory.sol";
import {ILiquidityLocker} from "src/locker/ILiquidityLocker.sol";

// Protocol Contracts, Types and Utils
import {ModuleInitializer} from "src/initializer/ModuleInitializer.sol";
import {PoolConfig, ActivationScope, ActivationContext} from "src/common/Types.sol";
import {Utils} from "src/common/Utils.sol";
import {Roles} from "src/common/Roles.sol";
import {V3Constants} from "src/common/V3Constants.sol";

/**
 * @title Protocol Activator Implementation
 * @author foreshadow.xyz | cordona.tech
 * @notice Orchestration engine that coordinates pool creation and liquidity operations
 * @dev Implements the middle layer in the protocol's security architecture,
 *      functioning as an internal admin for execution components while being
 *      controlled by the Protocol Manager.
 *
 *      Security architecture:
 *      - Operates as internal admin for factories and locker
 *      - Enforces validation before execution
 *      - Implements single-use activation pattern
 *      - Manages temporary ownership for locked liquidity (under specific condition)
 *
 *      Activation process:
 *      1. Configuration validation
 *         - Validates pool configuration parameters
 *         - Verifies scope consistency (V2/V3 activation flags)
 *         - Ensures sufficient ETH for operations and fees
 *
 *      2. Component orchestration
 *         - Creates V2 pools (Token/WETH & Token/Pair)
 *         - Creates V3 pools with configurable fee tiers
 *         - Manages liquidity locking with secure ownership transitions
 *
 * @custom:security-contact web3.security@cordona.tech
 */
contract ProtocolActivator is IProtocolActivator, ModuleInitializer {
    using Utils for uint256;
    using SafeERC20 for IERC20;

    // [ERRORS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    error ProtocolActivator__AlreadyActivated();
    error ProtocolActivator__InvalidScope(string errorDetails);
    error ProtocolActivator__InvalidFeeTier(uint24 invalidFee);
    error ProtocolActivator__InsufficientETHTransfer(uint256 invalid, uint256 expected);
    error ProtocolActivator__DeadlineExceedsThreshold(uint256 deadline, uint256 threshold);

    // [CONSTANTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @dev UNCX locker flat fee per lock operation
    uint256 private constant LOCKER_ETH_FLAT_FEE = 0.1 ether;

    /// @dev Security limit for pool deadline to prevent extended time locks
    uint256 private constant MAX_ALLOWED_DEADLINE = 30 minutes;

    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    bool public s_activated;

    // [EVENTS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event ProtocolActivated(bool indexed v2PoolsCreated, bool indexed v3PoolsCreated, bool indexed v2LiquidityLocked);

    // [PUBLIC] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @inheritdoc IProtocolActivator
    function activate(ActivationContext calldata context)
        external
        payable
        override
        onlyRole(Roles.ADMIN_ROLE)
        initialized
        validAddress(context.config.liquidityTokensRecipient)
        validAddress(context.config.token)
        validAddress(context.config.pair)
        validAddress(context.v2Factory)
        validAddress(context.v3Factory)
        validAddress(context.liquidityLocker)
        positiveValue(context.config.wethLiquidity)
        positiveValue(context.config.tokenLiquidity)
        positiveValue(context.config.pairLiquidity)
    {
        if (s_activated) {
            revert ProtocolActivator__AlreadyActivated();
        }

        _validateConfig(context.config);
        _validateScope(context.scope);

        (uint256 perPoolWethLiquidity) = _validateEthTransferAndComputeEthDistribution(msg.value, context);

        s_activated = true;

        emit ProtocolActivated(context.scope.createV2Pools, context.scope.createV3Pools, context.scope.lockV2Liquidity);

        if (context.scope.createV2Pools) {
            _createV2PoolsAndLockLiquidity(context, perPoolWethLiquidity);
        }

        if (context.scope.createV3Pools) {
            _createV3Pools(context, perPoolWethLiquidity);
        }
    }

    // [PRIVATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    function _validateConfig(PoolConfig calldata config) private pure {
        if (config.deadline > MAX_ALLOWED_DEADLINE) {
            revert ProtocolActivator__DeadlineExceedsThreshold(config.deadline, MAX_ALLOWED_DEADLINE);
        }

        if (
            config.fee != V3Constants.FEE_LOW && config.fee != V3Constants.FEE_MEDIUM
                && config.fee != V3Constants.FEE_HIGH
        ) {
            revert ProtocolActivator__InvalidFeeTier(config.fee);
        }
    }

    function _validateScope(ActivationScope calldata scope) private pure {
        if (!scope.createV2Pools && !scope.createV3Pools) {
            revert ProtocolActivator__InvalidScope("No pools selected for activation");
        }

        if (!scope.createV2Pools && scope.lockV2Liquidity) {
            revert ProtocolActivator__InvalidScope("Cannot lock v2 liquidity without activating V2 pools");
        }
    }

    /// @dev Validates ETH transfer and calculates distribution parameters for pool operations
    ///
    ///      Scope:
    ///      1. Validates sufficient ETH was provided for selected operations
    ///      2. Calculates per-pool liquidity distribution
    ///
    ///      Dynamic Validation Strategy:
    ///      The function determines required ETH based on selected pool types
    ///      and whether V2 pools will be locked, ensuring precise validation
    ///      for any activation configuration.
    ///
    ///      Security Check Components:
    ///      1. Pool Type Calculation
    ///         ├── Checks which pool types are being created (V2, V3, or both)
    ///         ├── Dynamically calculates required ETH based on active pool types
    ///         └── Prevents overpayment requirements for partial activations
    ///
    ///      2. Locking Fee Calculation
    ///         ├── V2 locking follows all-or-nothing pattern (both pools or none)
    ///         ├── Each lock costs exactly 0.1 ETH (UNCX platform fee)
    ///         └── Total locking fees only included when V2 pools are locked
    ///
    ///      Example Scenarios:
    ///      - V2 only: wethLiquidity * 1
    ///      - V3 only: wethLiquidity * 1
    ///      - V2+V3: wethLiquidity * 2
    ///      - V2 with locking: wethLiquidity * 1 + (0.1 ETH * 2)
    ///      - V2+V3 with locking: wethLiquidity * 2 + (0.1 ETH * 2)
    ///
    /// @param ethTransfer Total ETH transferred with the function call
    /// @param context Complete activation context including scope and configuration
    /// @return perPoolTypeWethLiquidity Amount of ETH allocated per pool type
    function _validateEthTransferAndComputeEthDistribution(uint256 ethTransfer, ActivationContext calldata context)
        private
        pure
        returns (uint256 perPoolTypeWethLiquidity)
    {
        uint256 descaledEthTransfer = ethTransfer.descaleEth();
        uint256 lockCount = (context.scope.createV2Pools && context.scope.lockV2Liquidity) ? 2 : 0;
        uint256 descaledLockerFees = (LOCKER_ETH_FLAT_FEE * lockCount).descaleEth();
        uint256 lockingFeesTotal = LOCKER_ETH_FLAT_FEE * lockCount;
        uint256 poolTypeCount = 0;

        if (context.scope.createV2Pools) poolTypeCount++;
        if (context.scope.createV3Pools) poolTypeCount++;

        uint256 wethLiquidityTotal = context.config.wethLiquidity * poolTypeCount;
        uint256 expected = wethLiquidityTotal + descaledLockerFees;

        if (descaledEthTransfer < expected) {
            revert ProtocolActivator__InsufficientETHTransfer(descaledEthTransfer, expected);
        }

        perPoolTypeWethLiquidity = poolTypeCount > 0 ? (ethTransfer - lockingFeesTotal) / poolTypeCount : 0;
    }

    /// @dev Creates V2 pools and handles liquidity locking through a secure temporary ownership pattern
    ///
    ///      Temporary Ownership Security Pattern:
    ///      This function implements a critical security mechanism where LP token ownership
    ///      follows different paths depending on whether locking is enabled:
    ///
    ///      Why Temporary Ownership Is Required:
    ///      └── UNCX locker requires that msg.sender owns the LP tokens before locking
    ///      └── When locking is enabled, this contract must temporarily become the token owner
    ///           to satisfy this requirement
    ///
    ///      Ownership Flow:
    ///      1. Initial Assignment
    ///         ├── If locking enabled: LP tokens minted to ProtocolActivator (this contract)
    ///         └── If no locking: LP tokens minted directly to configured recipient
    ///
    ///      2. Pool Creation & Liquidity Provision
    ///         ├── Creates token/pair pool with assigned ownership
    ///         └── Creates token/WETH pool with assigned ownership
    ///
    ///      3. Secure Locking Process (when enabled)
    ///         ├── ProtocolActivator transfers LP tokens to LiquidityLocker
    ///         └── LiquidityLocker sets user-specified recipient as the ultimate withdrawer
    ///
    ///      Security Guarantee: Even though ownership temporarily passes through this contract,
    ///      the final recipient specified in configuration will be the only address able to
    ///      withdraw the liquidity when the lock period expires.
    ///
    /// @param context Activation parameters including tokens and recipients
    /// @param perPoolWethLiquidity WETH amount for each pool's liquidity
    function _createV2PoolsAndLockLiquidity(ActivationContext calldata context, uint256 perPoolWethLiquidity) private {
        IUniswapV2PoolFactory v2Factory = IUniswapV2PoolFactory(context.v2Factory);

        address transactionalV2LiquidityOwner =
            context.scope.lockV2Liquidity ? address(this) : context.config.liquidityTokensRecipient;

        (address liquidityTokenA, uint256 liquidityA) = v2Factory.createV2Pool(
            context.config.token,
            context.config.pair,
            transactionalV2LiquidityOwner,
            context.config.tokenLiquidity,
            context.config.pairLiquidity,
            context.config.deadline
        );

        (address liquidityTokenB, uint256 liquidityB) = v2Factory.createV2WethPool{value: perPoolWethLiquidity}(
            context.config.token, transactionalV2LiquidityOwner, context.config.tokenLiquidity, context.config.deadline
        );

        if (context.scope.lockV2Liquidity) {
            _lockLiquidity(context, liquidityTokenA, liquidityA, transactionalV2LiquidityOwner);
            _lockLiquidity(context, liquidityTokenB, liquidityB, transactionalV2LiquidityOwner);
        }
    }

    /// @dev Executes V2 liquidity locking with secure ownership transition
    ///
    ///      Security Flow & Integration Design:
    ///      1. Ownership Transition Process
    ///         ├── ProtocolActivator holds LP tokens temporarily (from pool creation)
    ///         ├── This function transfers tokens to LiquidityLocker contract
    ///         └── LiquidityLocker establishes user-specified recipient as ultimate withdrawer
    ///
    ///      2. UNCX Integration Details
    ///         ├── Pays required platform fee (0.1 ETH per lock operation)
    ///         ├── Implements compliant token transfer sequence
    ///         └── Sets up proper withdrawal permissions
    ///
    ///      Key Security Considerations:
    ///      - Uses SafeERC20 for protected token transfers
    ///      - Atomically executes entire lock operation
    ///      - Preserves proper ownership chain despite temporary transitions
    ///      - Ensures specified recipient retains exclusive withdrawal rights
    ///
    /// @param context Protocol configuration context
    /// @param liquidityToken LP token contract address to lock
    /// @param liquidity Amount of LP tokens to lock
    /// @param liquidityTokenRecipient Final recipient with withdrawal rights
    function _lockLiquidity(
        ActivationContext calldata context,
        address liquidityToken,
        uint256 liquidity,
        address liquidityTokenRecipient
    ) private {
        ILiquidityLocker liquidityLocker = ILiquidityLocker(context.liquidityLocker);
        IERC20(liquidityToken).safeTransfer(context.liquidityLocker, liquidity);
        liquidityLocker.lockV2Liquidity{value: LOCKER_ETH_FLAT_FEE}(liquidityToken, liquidity, liquidityTokenRecipient);
    }

    function _createV3Pools(ActivationContext calldata context, uint256 perPoolWethLiquidity) private {
        IUniswapV3PoolFactory v3Factory = IUniswapV3PoolFactory(context.v3Factory);

        v3Factory.createV3Pool(
            context.config.token,
            context.config.pair,
            context.config.liquidityTokensRecipient,
            context.config.tokenLiquidity,
            context.config.pairLiquidity,
            context.config.deadline,
            context.config.fee
        );

        v3Factory.createV3WethPool{value: perPoolWethLiquidity}(
            context.config.token,
            context.config.liquidityTokensRecipient,
            context.config.tokenLiquidity,
            context.config.deadline,
            context.config.fee
        );
    }
}
