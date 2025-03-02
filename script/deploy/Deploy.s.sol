// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "lib/forge-std/src/Script.sol";
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";
import {UniswapV3PoolFactory} from "src/factories/v3/UniswapV3PoolFactory.sol";
import {LiquidityLocker} from "src/locker/LiquidityLocker.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";
import {ProtocolManager} from "src/manager/ProtocolManager.sol";
import {DeploymentConfig} from "./DeploymentConfig.s.sol";
import {ProtocolConfig, ProtocolDeployment, CoreDeployment, PeripheryDeployment} from "./DeploymentTypes.s.sol";

contract Deploy is Script {
    function run() public returns (ProtocolDeployment memory, ProtocolConfig memory) {
        ProtocolConfig memory config = new DeploymentConfig().loadConfigFromEnvironment();

        vm.startBroadcast(config.core.adminAddr);

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

        address internalActivator = address(deployedProtocolActivator);
        
        deployedProtocolActivator.initialize("Protocol Activator", address(deployedManager));
        deployedV2Factory.initialize("V2 Pool Factory", internalActivator);
        deployedV3Factory.initialize("V3 Pool Factory", internalActivator);
        deployedLiquidityLocker.initialize("V2 Liquidity Locker", internalActivator);

        vm.stopBroadcast();

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
