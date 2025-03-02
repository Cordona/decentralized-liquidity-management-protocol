// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Protocol Interfaces
import {IProtocolManager} from "src/manager/IProtocolManager.sol";
import {IUniswapV2PoolFactory} from "src/factories/v2/IUniswapV2PoolFactory.sol";
import {IUniswapV3PoolFactory} from "src/factories/v3/IUniswapV3PoolFactory.sol";
import {ILiquidityLocker} from "src/locker/ILiquidityLocker.sol";
import {IProtocolActivator} from "src/activator/IProtocolActivator.sol";

// Protocol Contracts & Utils
import {AdminInitializer} from "src/common/AdminInitializer.sol";
import {Roles} from "src/common/Roles.sol";
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {PoolConfig, ActivationScope, ActivationContext} from "src/common/Types.sol";

/**
 * @title Protocol Manager Implementation
 * @author foreshadow.xyz | cordona.tech
 * @notice Gateway contract that serves as the protocol's primary access control boundary
 * @dev Implements the central security checkpoint in the protocol's role-based architecture.
 *      The Manager creates a clear separation between external administration and
 *      internal execution, enforcing privilege boundaries through delegated operations.
 *
 *      Security architecture:
 *      - Acts as the sole entry point for external admin (deployer) operations
 *      - Delegates execution to Protocol Activator (internal admin)
 *      - Establishes unidirectional privilege flow (Deployer → Manager → Activator → Components)
 *      - Implements reentrancy protection for all payable functions
 *
 *      Protocol lifecycle:
 *      1. Deployment phase
 *         - Components deployed with initial roles (see Deploy.s.sol)
 *         - Role transitions established through ModuleInitializer
 *         - Manager configured as the activator's admin
 *
 *      2. Post-deployment phase
 *         - Protocol activation via Manager.activate()
 *         - Liquidity provision and optional locking through ProtocolActivator
 *         - Supply management via remainder recipient functions
 *         - Ongoing position monitoring through view functions
 *
 * @custom:security-contact web3.security@cordona.tech
 */
contract ProtocolManager is IProtocolManager, AdminInitializer, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    address public s_supplyRemainderRecipient;

    // [IMMUTABLE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ProtocolToken public immutable i_protocolToken;
    IProtocolActivator public immutable i_protocolActivator;
    IUniswapV2PoolFactory public immutable i_v2PoolFactory;
    IUniswapV3PoolFactory public immutable i_v3PoolFactory;
    ILiquidityLocker public immutable i_liquidityLocker;

    event NewSupplyRemainderRecipient(address indexed supplyRecipient);

    // [CONSTRUCTOR] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    constructor(
        address protocolToken,
        address protocolActivator,
        address v2PoolFactory,
        address v3PoolFactory,
        address liquidityLocker,
        address supplyRemainderRecipient
    )
        validAddress(protocolToken)
        validAddress(protocolActivator)
        validAddress(v2PoolFactory)
        validAddress(v3PoolFactory)
        validAddress(liquidityLocker)
        validAddress(supplyRemainderRecipient)
    {
        i_protocolToken = ProtocolToken(protocolToken);
        i_protocolActivator = IProtocolActivator(protocolActivator);
        i_v2PoolFactory = IUniswapV2PoolFactory(v2PoolFactory);
        i_v3PoolFactory = IUniswapV3PoolFactory(v3PoolFactory);
        i_liquidityLocker = ILiquidityLocker(liquidityLocker);

        s_supplyRemainderRecipient = supplyRemainderRecipient;
    }

    // [EXTERNAL] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @inheritdoc IProtocolManager
    function activate(PoolConfig calldata config, ActivationScope calldata scope)
        external
        payable
        nonReentrant
        onlyRole(Roles.ADMIN_ROLE)
    {
        ActivationContext memory context = ActivationContext({
            config: config,
            scope: scope,
            v2Factory: address(i_v2PoolFactory),
            v3Factory: address(i_v3PoolFactory),
            liquidityLocker: address(i_liquidityLocker)
        });

        i_protocolActivator.activate{value: msg.value}(context);
    }

    /// @inheritdoc IProtocolManager
    function changeSupplyRemainderRecipient(address supplyRecipient)
        external
        override
        onlyRole(Roles.ADMIN_ROLE)
        validAddress(supplyRecipient)
    {
        s_supplyRemainderRecipient = supplyRecipient;
        emit NewSupplyRemainderRecipient(supplyRecipient);
    }

    /// @inheritdoc IProtocolManager
    function transferSupplyRemainder(address owner) external override onlyRole(Roles.ADMIN_ROLE) validAddress(owner) {
        IERC20(i_protocolToken).safeTransferFrom(owner, s_supplyRemainderRecipient, i_protocolToken.balanceOf(owner));
    }

    // [VIEW] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @inheritdoc IProtocolManager
    function getV2LiquidityDetails(address tokenA, address tokenB, address liquidityOwner)
        external
        view
        override
        returns (address liquidityToken, uint256 liquidity)
    {
        return i_v2PoolFactory.getLiquidityDetails(tokenA, tokenB, liquidityOwner);
    }

    /// @inheritdoc IProtocolManager
    function getV3LiquidityDetails(address liquidityOwner)
        external
        view
        override
        returns (uint256 tokenId, uint128 liquidity, uint24 fee)
    {
        return i_v3PoolFactory.getLiquidityDetails(liquidityOwner);
    }

    /// @inheritdoc IProtocolManager
    function getLiquidityLockDetails(address _owner, address _lpToken)
        external
        view
        override
        returns (
            uint256 lockDate,
            uint256 amount,
            uint256 initialAmount,
            uint256 unlockDate,
            uint256 lockId,
            address owner
        )
    {
        return i_liquidityLocker.getV2LiquidityLockDetails(_owner, _lpToken);
    }
}
