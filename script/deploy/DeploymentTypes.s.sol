// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {ProtocolManager} from "src/manager/ProtocolManager.sol";
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";
import {UniswapV3PoolFactory} from "src/factories/v3/UniswapV3PoolFactory.sol";
import {LiquidityLocker} from "src/locker/LiquidityLocker.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";

struct ProtocolConfig {
    CoreConfig core;
    PeripheryConfig periphery;
    InfraConfig infra;
}

struct CoreConfig {
    string name;
    string symbol;
    address adminAddr;
    address remainderRecipientAddr;
    uint256 totalSupply;
}

struct PeripheryConfig {
    address wethAddr;
    UniswapV2Config uniswapV2;
    UniswapV3Config uniswapV3;
    LiquidityLockerConfig locker;
}

struct InfraConfig {
    string rpcUrl;
}

struct UniswapV2Config {
    address routerAddr;
    address factoryAddr;
}

struct UniswapV3Config {
    address positionManagerAddr;
}

struct LiquidityLockerConfig {
    address liquidityLockerAddr;
    uint256 lockDurationDays;
}

struct ProtocolDeployment {
    CoreDeployment core;
    PeripheryDeployment periphery;
}

struct CoreDeployment {
    ProtocolToken token;
    ProtocolManager manager;
}

struct PeripheryDeployment {
    UniswapV2PoolFactory v2Factory;
    UniswapV3PoolFactory v3Factory;
    LiquidityLocker liquidityLocker;
    ProtocolActivator protocolActivator;
}
