// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "lib/forge-std/src/Script.sol";
import "./DeploymentVariables.sol";
import {
    ProtocolConfig,
    CoreConfig,
    PeripheryConfig,
    ActivationConfig,
    InfraConfig,
    UniswapV2Config,
    UniswapV3Config,
    LiquidityLockerConfig
} from "./DeploymentTypes.s.sol";

contract DeploymentConfig is Script {
    function loadConfigFromEnvironment() external view returns (ProtocolConfig memory) {
        return ProtocolConfig({
            core: _loadCoreConfig(),
            periphery: _loadPeripheryConfig(),
            activation: _loadActivationConfig(),
            infra: _loadInfraConfig()
        });
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

    function _loadActivationConfig() private view returns (ActivationConfig memory) {
        return ActivationConfig({
            protocolTokenLiquidity: vm.envUint(PROTOCOL_TOKEN_LIQUIDITY_ENV_VAR),
            pairTokenLiquidity: vm.envUint(PAIR_TOKEN_LIQUIDITY_ENV_VAR),
            wethLiquidity: vm.envUint(WETH_LIQUIDITY_ENV_VAR),
            liquidityTokensRecipient: vm.envAddress(LIQUIDITY_TOKENS_RECIPIENT_ENV_VAR),
            fee: uint24(vm.envUint(FEE_ENV_VAR)),
            deadline: vm.envUint(DEADLINE_ENV_VAR)
        });
    }

    function _loadInfraConfig() private view returns (InfraConfig memory) {
        return InfraConfig({rpcUrl: vm.envString(RPC_URL_ENV_VAR)});
    }
}
