// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {Script} from "lib/forge-std/src/Script.sol";

// Protocol Contracts
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";
import {UniswapV3PoolFactory} from "src/factories/v3/UniswapV3PoolFactory.sol";
import {LiquidityLocker} from "src/locker/LiquidityLocker.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";
import {ProtocolManager} from "src/manager/ProtocolManager.sol";

// Protocol configurations and Types
import {DeploymentConfig} from "./DeploymentConfig.s.sol";
import {ProtocolConfig, ProtocolDeployment, CoreDeployment, PeripheryDeployment} from "./DeploymentTypes.s.sol";

/**
 * @title DLMP Protocol Deployment Script
 * @author foreshadow.xyz | cordona.tech
 * @notice Responsible for deploying and initializing the complete protocol
 * @dev This script handles the entire deployment lifecycle:
 *
 *      Deployment architecture:
 *      - Creates all core protocol components (Token, Manager)
 *      - Deploys peripheral components (Factories, Locker, Activator)
 *      - Establishes secure initialization relationships
 *      - Sets up the unidirectional privilege flow architecture
 *
 *      Security relationships established:
 *      - Protocol Manager becomes the Activator's admin
 *      - Activator becomes admin for Factories and Locker
 *      - All components receive proper names for easier identification
 *      - Deployer retains TOKEN_RESCUER_ROLE on all components
 *
 *      This deployment follows a defense-in-depth strategy:
 *      1. External admin (deployer) → Protocol Manager
 *      2. Protocol Manager → Protocol Activator
 *      3. Protocol Activator → Execution Components (Factories, Locker)
 *
 *      The resulting deployment creates a secure foundation that enforces:
 *      - Clear boundaries of responsibility
 *      - Privilege separation between administration and execution
 *      - Emergency recovery capabilities while maintaining least privilege
 *
 * @custom:security-contact web3.security@cordona.tech
 */
contract Deploy is Script {
    function run() public returns (ProtocolDeployment memory, ProtocolConfig memory) {
        ProtocolConfig memory config = new DeploymentConfig().loadConfigFromEnvironment();

        vm.startBroadcast(config.core.adminAddr);

        // Deploy core protocol components
        ProtocolToken deployedToken = new ProtocolToken(config.core.name, config.core.symbol, config.core.totalSupply);

        ProtocolActivator deployedProtocolActivator = new ProtocolActivator();

        UniswapV2PoolFactory deployedV2Factory = new UniswapV2PoolFactory(
            config.periphery.uniswapV2.factoryAddr, config.periphery.uniswapV2.routerAddr, config.periphery.wethAddr
        );

        UniswapV3PoolFactory deployedV3Factory =
            new UniswapV3PoolFactory(config.periphery.uniswapV3.positionManagerAddr, config.periphery.wethAddr);

        LiquidityLocker deployedLiquidityLocker =
            new LiquidityLocker(config.periphery.locker.liquidityLockerAddr, config.periphery.locker.lockDurationDays);

        ProtocolManager deployedManager = new ProtocolManager(
            address(deployedToken),
            address(deployedProtocolActivator),
            address(deployedV2Factory),
            address(deployedV3Factory),
            address(deployedLiquidityLocker),
            config.core.remainderRecipientAddr
        );

        // Store activator address for initialization
        address internalActivator = address(deployedProtocolActivator);

        // Initialize all components with proper admins
        deployedProtocolActivator.initialize("Protocol Activator", address(deployedManager));
        deployedV2Factory.initialize("V2 Pool Factory", internalActivator);
        deployedV3Factory.initialize("V3 Pool Factory", internalActivator);
        deployedLiquidityLocker.initialize("V2 Liquidity Locker", internalActivator);

        vm.stopBroadcast();

        // Create and return deployment metadata
        ProtocolDeployment memory deployment = ProtocolDeployment({
            core: CoreDeployment({token: deployedToken, manager: deployedManager}),
            periphery: PeripheryDeployment({
                v2Factory: deployedV2Factory,
                v3Factory: deployedV3Factory,
                liquidityLocker: deployedLiquidityLocker,
                protocolActivator: deployedProtocolActivator
            })
        });

        return (deployment, config);
    }
}
