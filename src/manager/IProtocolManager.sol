// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Types
import {PoolConfig, ActivationScope} from "src/common/Types.sol";

/**
 * @title Protocol Manager Interface
 * @author foreshadow.xyz | cordona.tech
 * @notice Central gateway interface for protocol management
 * @dev Serves as the primary entry point in the protocol's security architecture:
 *
 *      Security Flow (Post-Deployment):
 *      Deployer (External Admin)
 *         └── Protocol Manager (Entry Point)
 *             └── Protocol Activator (Internal Admin)
 *                 ├── V2/V3 Pool Factories
 *                 └── Liquidity Locker
 *
 *      Key security considerations:
 *      - Only the deployer can call critical functions (ADMIN_ROLE)
 *      - All liquidity operations flow through this single gateway
 *      - Implements strict delegation pattern for component isolation
 *
 * @custom:security-contact web3.security@cordona.tech
 */
interface IProtocolManager {
    /// @notice Activates the protocol by deploying liquidity pools and initializing security measures
    /// @dev Security & Execution Flow:
    ///      Access: Admin role only (Deployer)
    ///      Process:
    ///      1. Deploys specified pools (V2/V3)
    ///      2. Initializes liquidity locks (if enabled)
    ///
    /// @param config Pool deployment configuration
    /// @param scope Activation scope (Uniswap V2/V3 liquidity pools activation and V2 liquidity locking)
    /// @custom:security Requires msg.value if WETH pools are included
    function activate(PoolConfig calldata config, ActivationScope calldata scope) external payable;

    /// @notice Transfers the remaining supply of protocol tokens from a user to the designated recipient
    /// @dev Security & Execution Flow:
    ///      Access: Admin role only (Deployer)
    ///      Process:
    ///      1. The supply owner must pre-approve the ProtocolManager to transfer the supply remainder
    ///      2. The ProtocolManager transfers the supply remainder
    /// @param owner The address from which the remaining supply will be transferred
    function transferSupplyRemainder(address owner) external;

    /// @notice Updates the recipient address for the remaining protocol token supply
    /// @dev Access: Admin role only (Deployer)
    /// @param supplyRecipient The new recipient address for the protocol's remaining token supply
    function changeSupplyRemainderRecipient(address supplyRecipient) external;

    /// @notice Retrieves details of a liquidity lock for a given LP token and owner
    /// @dev Calls getV2LiquidityLockDetails() on ILiquidityLocker
    /// @param _owner The address of the liquidity lock owner
    /// @param _lpToken The address of the liquidity token
    /// @return lockDate The timestamp when the lock was created
    /// @return amount The currently locked liquidity amount
    /// @return initialAmount The initial amount locked at the time of creation
    /// @return unlockDate The timestamp when liquidity can be withdrawn
    /// @return lockId The unique identifier of the locked liquidity
    /// @return owner The address that owns the locked liquidity
    function getLiquidityLockDetails(address _owner, address _lpToken)
        external
        view
        returns (
            uint256 lockDate,
            uint256 amount,
            uint256 initialAmount,
            uint256 unlockDate,
            uint256 lockId,
            address owner
        );

    /// @notice Retrieves details of a Uniswap V2 liquidity pool
    /// @dev Calls getLiquidityDetails() on IUniswapV2PoolFactory
    /// @param tokenA The first token in the liquidity pair
    /// @param tokenB The second token in the liquidity pair
    /// @param liquidityOwner The address whose liquidity balance is being queried
    /// @return liquidityToken The address of the liquidity token representing the pool
    /// @return liquidity The amount of liquidity tokens owned by `liquidityOwner`
    function getV2LiquidityDetails(address tokenA, address tokenB, address liquidityOwner)
        external
        view
        returns (address liquidityToken, uint256 liquidity);

    /// @notice Retrieves details of a Uniswap V3 liquidity position
    /// @dev Calls getLiquidityDetails() on IUniswapV3PoolFactory
    /// @param liquidityOwner The address whose liquidity position is being queried
    /// @return tokenId The unique ID of the minted liquidity position
    /// @return liquidity The amount of liquidity in the position
    /// @return fee The Uniswap V3 pool fee tier for the position
    function getV3LiquidityDetails(address liquidityOwner)
        external
        view
        returns (uint256 tokenId, uint128 liquidity, uint24 fee);
}
