// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "lib/forge-std/src/Script.sol";
import "./DeploymentVariables.sol";
import {
    ProtocolConfig,
    CoreConfig,
    PeripheryConfig,
    InfraConfig,
    UniswapV2Config,
    UniswapV3Config,
    LiquidityLockerConfig
} from "./DeploymentTypes.s.sol";

contract DeploymentConfig is Script {
    function loadConfigFromEnvironment() public view returns (ProtocolConfig memory) {
        return ProtocolConfig({core: _loadCoreConfig(), periphery: _loadPeripheryConfig(), infra: _loadInfraConfig()});
    }

    function _loadCoreConfig() private view returns (CoreConfig memory) {
        return CoreConfig({
            name: vm.envString(TOKEN_NAME_ENV_VAR),
            symbol: vm.envString(TOKEN_SYMBOL_ENV_VAR),
            adminAddr: vm.envAddress(ADMIN_ENV_VAR),
            remainderRecipientAddr: vm.envAddress(SUPPLY_REMAINDER_RECIPIENT_ENV_VAR),
            totalSupply: vm.envUint(TOKEN_TOTAL_SUPPLY_ENV_VAR)
        });
    }

    function _loadPeripheryConfig() private view returns (PeripheryConfig memory) {
        return PeripheryConfig({
            wethAddr: vm.envAddress(WETH_ADDR_ENV_VAR),
            uniswapV2: UniswapV2Config({
                routerAddr: vm.envAddress(UNISWAP_V2_ROUTER_ADDR_ENV_VAR),
                factoryAddr: vm.envAddress(UNISWAP_V2_FACTORY_ADDR_ENV_VAR)
            }),
            uniswapV3: UniswapV3Config({positionManagerAddr: vm.envAddress(UNISWAP_V3_POSITION_MANAGER_ADDR_ENV_VAR)}),
            locker: LiquidityLockerConfig({
                liquidityLockerAddr: vm.envAddress(UNISWAP_V2_LIQUIDITY_LOCKER_ADDR_ENV_VAR),
                lockDurationDays: vm.envUint(LOCK_DURATION_DAYS_ENV_VAR)
            })
        });
    }

    function _loadInfraConfig() private view returns (InfraConfig memory) {
        return InfraConfig({rpcUrl: vm.envString(RPC_URL_ENV_VAR)});
    }
}
