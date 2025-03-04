// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {Script} from "lib/forge-std/src/Script.sol";

// Protocol Types
import "script/activate/ActivationVariables.sol";
import {ProtocolDeployments, PoolConfig, ActivationScope} from "src/common/Types.sol";

contract ActivationConfig is Script {
    function loadActivationConfig()
        public
        view
        returns (
            address admin,
            ProtocolDeployments memory protocolDeployments,
            PoolConfig memory poolConfig,
            ActivationScope memory activationScope
        )
    {
        admin = vm.envAddress(ADMIN_ENV_VAR);

        protocolDeployments = ProtocolDeployments({
            manager: vm.envAddress(DEPLOYED_PROTOCOL_MANAGER_ADDR_ENV_VAR),
            v2factory: vm.envAddress(DEPLOYED_V2_PROTOCOL_FACTORY_ADDR_ENV_VAR),
            v3factory: vm.envAddress(DEPLOYED_V3_PROTOCOL_FACTORY_ADDR_ENV_VAR)
        });

        poolConfig = PoolConfig({
            liquidityTokensRecipient: vm.envAddress(LIQUIDITY_TOKENS_RECIPIENT_ENV_VAR),
            protocolToken: vm.envAddress(PROTOCOL_TOKEN_ADDR_EVN_VAR),
            pairToken: vm.envAddress(PAIR_TOKEN_ADDR_EVN_VAR),
            weth: vm.envAddress(WETH_ADDR_ENV_VAR),
            v3PoolFee: uint24(vm.envUint(V3_POOL_FEE_ENV_VAR)),
            liquidityLockerEthFee: vm.envUint(LIQUIDITY_LOCKER_FEE_ENV_VAR),
            deadline: vm.envUint(DEADLINE_ENV_VAR),
            protocolTokenLiquidity: vm.envUint(PROTOCOL_TOKEN_LIQUIDITY_ENV_VAR),
            pairTokenLiquidity: vm.envUint(PAIR_TOKEN_LIQUIDITY_ENV_VAR),
            wethLiquidity: vm.envUint(WETH_LIQUIDITY_ENV_VAR)
        });

        activationScope = ActivationScope({
            createV2Pools: vm.envBool(CREATE_V2_POOLS_ENV_VAR),
            createV3Pools: vm.envBool(CREATE_V3_POOLS_ENV_VAR),
            lockV2Liquidity: vm.envBool(LOCK_V2_LIQUIDITY_ENV_VAR)
        });
    }
}
