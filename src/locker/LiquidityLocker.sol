// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Protocol Interfaces
import {ILiquidityLocker} from "src/locker/ILiquidityLocker.sol";

// Protocol Contracts & Utils
import {UNCXUniswapV2Locker} from "src/locker/UNCXUniswapV2Locker.sol";
import {ModuleInitializer} from "src/initializer/ModuleInitializer.sol";
import {Roles} from "src/common/Roles.sol";

/**
 * @title Liquidity Locker Implementation
 * @author foreshadow.xyz | cordona.tech
 * @notice Secure integration with UNCX for Uniswap V2 liquidity locking
 * @dev Implements a protected execution component in the protocol's security architecture,
 *      serving as the secure bridge between the protocol and external locking services.
 *
 *      Security architecture:
 *      - Operates exclusively under ProtocolActivator's authorization
 *      - Implements ModuleInitializer for secure role transition
 *      - Enforces minimum lock duration (365 days by default)
 *      - Provides defensive error handling for external service calls
 *
 *      UNCX Integration:
 *      1. Locking Mechanism
 *         - Direct interface with UNCX V2 Locker service
 *         - Fee forwarding (0.1 ETH per lock)
 *         - Safe token approval and transfer processes
 *         - Withdrawal rights secured to specified recipient
 *
 *      2. Safety Considerations
 *         - Handles external service failures gracefully
 *         - Uses special values to indicate lock status
 *         - Transparent lock state reporting
 *         - Event emission for all locking operations
 *
 * @custom:security-contact web3.security@cordona.tech
 */
contract LiquidityLocker is ILiquidityLocker, ModuleInitializer {
    using SafeERC20 for IERC20;

    // [CONSTANT] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @dev Minimum lock duration enforced
    uint256 private constant MIN_LOCK_DURATION_DAYS = 365;

    /// @dev First lock index in UNCX locker
    uint256 private constant LOCKER_FIRST_INDEX = 0;

    /// @dev Special value indicating no lock exists
    uint256 private constant NO_LOCK_ID = type(uint256).max;

    /// @dev Required UNCX country code (1 = USA, default for this protocol)
    uint16 private constant DEFAULT_COUNTRY_CODE = 1;

    // [IMMUTABLE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    UNCXUniswapV2Locker public immutable i_v2Locker;
    uint256 public immutable i_lockDuration;

    // [EVENTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event V2LiquidityLocked(
        address indexed lpToken, uint256 indexed amount, address indexed withdrawer, uint256 unlockDate
    );

    // [CONSTRUCTOR] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    constructor(address v2Locker, uint256 lockDuration) validAddress(v2Locker) {
        if (lockDuration < MIN_LOCK_DURATION_DAYS) {
            revert LiquidityLocker__InvalidLockDuration(lockDuration, MIN_LOCK_DURATION_DAYS);
        }

        i_v2Locker = UNCXUniswapV2Locker(v2Locker);
        i_lockDuration = lockDuration;
    }

    // [EXTERNAL] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @inheritdoc ILiquidityLocker
    function lockV2Liquidity(address liquidityToken, uint256 liquidity, address withdrawer)
        external
        payable
        override
        onlyRole(Roles.ADMIN_ROLE)
        initialized
        validAddress(liquidityToken)
        validAddress(withdrawer)
    {
        uint256 unlockDate = block.timestamp + uint256(i_lockDuration) * 1 days;
        address noReferrer = ZERO_ADDRESS;

        emit V2LiquidityLocked(liquidityToken, liquidity, withdrawer, unlockDate);

        IERC20(liquidityToken).forceApprove(address(i_v2Locker), liquidity);

        i_v2Locker.lockLPToken{value: msg.value}(
            liquidityToken, liquidity, unlockDate, payable(noReferrer), true, payable(withdrawer), DEFAULT_COUNTRY_CODE
        );
    }

    /// @dev External Service Integration Pattern:
    ///      This function implements a defensive approach to external service calls:
    ///
    ///      Security Considerations:
    ///      - Uses try/catch to handle external service failures gracefully
    ///      - UNCX locker reverts when no lock exists for owner/token pair
    ///      - Returns standardized zero values with special NO_LOCK_ID marker on failure
    ///
    ///      Lock Identification:
    ///      - Valid locks return their actual UNCX lockID (starting from 0)
    ///      - Non-existent locks return type(uint256).max to avoid ambiguity
    ///      - This distinction prevents confusion between new locks (ID=0) and no locks
    function getV2LiquidityLockDetails(address lockOwner, address liquidityToken)
        external
        view
        returns (
            uint256 lockDate,
            uint256 amount,
            uint256 initialAmount,
            uint256 unlockDate,
            uint256 lockID,
            address owner
        )
    {
        try i_v2Locker.getUserLockForTokenAtIndex(lockOwner, liquidityToken, LOCKER_FIRST_INDEX) returns (
            UNCXUniswapV2Locker.TokenLock memory tokenLock
        ) {
            return (
                tokenLock.lockDate,
                tokenLock.amount,
                tokenLock.initialAmount,
                tokenLock.unlockDate,
                tokenLock.lockID,
                tokenLock.owner
            );
        } catch {
            return (ZERO_VALUE, ZERO_VALUE, ZERO_VALUE, ZERO_VALUE, NO_LOCK_ID, ZERO_ADDRESS);
        }
    }
}
