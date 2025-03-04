// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {Script} from "lib/forge-std/src/Script.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Protocol Contracts
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {IProtocolManager} from "src/manager/IProtocolManager.sol";

// Protocol configurations, Types and Utils
import {ActivationConfig} from "script/activate/ActivationConfig.sol";
import {ProtocolDeployments, PoolConfig, ActivationScope} from "src/common/Types.sol";
import {Utils} from "src/common/Utils.sol";

/**
 * @title Protocol Activation Script
 * @author foreshadow.xyz | cordona.tech
 * @notice Responsible for one-time activation of the DLMP protocol
 * @dev This script handles the critical protocol activation process:
 *
 *      Activation architecture:
 *      - Transfers protocol tokens to both V2 and V3 factories
 *      - Provides sufficient tokens for all pools (token-pair and token-WETH)
 *      - Calculates correct ETH amount based on activation scope
 *      - Activates the protocol via the ProtocolManager
 *
 *      This is a one-time operation that:
 *      - Must be executed by an address with the ADMIN_ROLE
 *      - Configures pool creation across both Uniswap V2 and V3
 *      - Sets up liquidity locking if enabled in activation scope
 *      - Cannot be repeated after successful execution
 *
 * @custom:security-contact web3.security@cordona.tech
 */
contract ActivateProtocol is Script {
    using Utils for uint256;
    using SafeERC20 for IERC20;

    // [CONSTANTS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    /// @notice Multiplier for protocol token funding
    /// @dev Each factory creates two pools using the protocol token:
    ///   - Protocol Token + Pair Token pool
    ///   - Protocol Token + WETH pool
    ///   This requires double the amount of protocol tokens to be transferred
    ///   to each factory compared to the per-pool liquidity configuration
    uint256 private constant PROTOCOL_TOKEN_POOL_MULTIPLIER = 2;

    // [ERRORS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    error ActivateProtocol__FactoryFundingFailed();

    // [MAIN EXECUTION] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    function run() public {
        (
            address admin,
            ProtocolDeployments memory protocolDeployments,
            PoolConfig memory poolConfig,
            ActivationScope memory activationScope
        ) = new ActivationConfig().loadActivationConfig();

        vm.startBroadcast(admin);

        // Fund V2 factory if needed
        if (activationScope.createV2Pools) {
            uint256 scaledProtocolAmount =
                poolConfig.protocolTokenLiquidity.safeScale(poolConfig.protocolToken) * PROTOCOL_TOKEN_POOL_MULTIPLIER;
            uint256 scaledPairAmount = poolConfig.pairTokenLiquidity.safeScale(poolConfig.pairToken);

            IERC20(poolConfig.protocolToken).safeTransfer(protocolDeployments.v2factory, scaledProtocolAmount);
            IERC20(poolConfig.pairToken).safeTransfer(protocolDeployments.v2factory, scaledPairAmount);
        }

        // Fund V3 factory if needed
        if (activationScope.createV3Pools) {
            uint256 scaledProtocolAmount =
                poolConfig.protocolTokenLiquidity.safeScale(poolConfig.protocolToken) * PROTOCOL_TOKEN_POOL_MULTIPLIER;
            uint256 scaledPairAmount = poolConfig.pairTokenLiquidity.safeScale(poolConfig.pairToken);

            IERC20(poolConfig.protocolToken).safeTransfer(protocolDeployments.v3factory, scaledProtocolAmount);
            IERC20(poolConfig.pairToken).safeTransfer(protocolDeployments.v3factory, scaledPairAmount);
        }

        // Calculate ETH for activation
        uint256 ethMultiplier = 0;
        if (activationScope.createV2Pools) ethMultiplier++;
        if (activationScope.createV3Pools) ethMultiplier++;

        // Base ETH for liquidity
        uint256 ethTransfer = poolConfig.wethLiquidity.safeScale(poolConfig.weth) * ethMultiplier;

        // Add locking fees if needed (0.1 ETH per V2 pool that needs locking)
        if (activationScope.lockV2Liquidity && activationScope.createV2Pools) {
            // We need 0.1 ETH for token-pair pool and 0.1 ETH for token-WETH pool
            ethTransfer += poolConfig.liquidityLockerEthFee * 2;
        }

        // Activate protocol
        IProtocolManager manager = IProtocolManager(protocolDeployments.manager);
        manager.activate{value: ethTransfer}(poolConfig, activationScope);

        vm.stopBroadcast();
    }
}
