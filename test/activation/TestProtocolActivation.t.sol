// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import {MockPairToken} from "test/mocks/MockPairToken.sol";

// Protocol Contracts
import {Deploy} from "script/deploy/Deploy.s.sol";
import {ActivateProtocol} from "script/activate/ActivateProtocol.s.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";

// Protocol configurations, Types and Utils
import {ProtocolConfig, ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";
import {Utils} from "src/common/Utils.sol";
import "script/deploy/DeploymentVariables.sol";

contract TestProtocolActivation is BaseTest {
    using Utils for uint256;
    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    ProtocolActivator s_protocolActivator;

    function setUp() public {
        vm.createSelectFork(vm.envString(RPC_URL_ENV_VAR));
        vm.startBroadcast(deployer());
        MockPairToken pairToken = new MockPairToken();
        vm.stopBroadcast();

        (ProtocolDeployment memory deployment, ProtocolConfig memory config) = new Deploy().run();

        s_protocolActivator = deployment.periphery.protocolActivator;

        address protocolManager = address(deployment.core.manager);
        address v2Factory = address(deployment.periphery.v2Factory);
        address v3Factory = address(deployment.periphery.v3Factory);
        address recipient = someAddress();
        address protocolTokenAddr = address(deployment.core.token);
        address pairTokenAddr = address(pairToken);
        uint24 v3PoolFee = TEST_FEE;
        uint256 lockerEthFee = 0.1 ether;
        uint256 deadLine = TEST_DEADLINE;
        uint256 protocolTokenLiquidity = TEST_PROTOCOL_TOKEN_LIQUIDITY;
        uint256 pairTokenLiquidity = TEST_PAIR_TOKEN_LIQUIDITY;
        uint256 wethLiquidity = TEST_WETH_LIQUIDITY;

        vm.setEnv("DEPLOYED_PROTOCOL_MANAGER_ADDR", vm.toString(protocolManager));
        vm.setEnv("DEPLOYED_V2_PROTOCOL_FACTORY_ADDR", vm.toString(v2Factory));
        vm.setEnv("DEPLOYED_V3_PROTOCOL_FACTORY_ADDR", vm.toString(v3Factory));
        vm.setEnv("LIQUIDITY_RECIPIENT", vm.toString(recipient));
        vm.setEnv("PROTOCOL_TOKEN_ADDRESS", vm.toString(protocolTokenAddr));
        vm.setEnv("PAIR_TOKEN_ADDRESS", vm.toString(pairTokenAddr));
        vm.setEnv("WETH_ADDR", vm.toString(config.periphery.wethAddr));
        vm.setEnv("V3_POOL_FEE", vm.toString(v3PoolFee));
        vm.setEnv("LIQUIDITY_LOCKER_FLAT_FEE", vm.toString(lockerEthFee));
        vm.setEnv("DEADLINE", vm.toString(deadLine));
        vm.setEnv("PROTOCOL_TOKEN_LIQUIDITY", vm.toString(protocolTokenLiquidity));
        vm.setEnv("PAIR_TOKEN_LIQUIDITY", vm.toString(pairTokenLiquidity));
        vm.setEnv("WETH_LIQUIDITY", vm.toString(wethLiquidity));
        vm.setEnv("CREATE_V2_POOLS", "true");
        vm.setEnv("CREATE_V3_POOLS", "true");
        vm.setEnv("LOCK_V2_LIQUIDITY", "true");
        vm.setEnv("ADMIN", "0xFa377a04AFc78d158bCD59E9eFeDa07b3d89c7A3");
    }

    function testShouldSuccessfullyActivateTheProtocol() public {
        // Given
        uint256 sufficientEth = 25 ether;
        vm.deal(0xFa377a04AFc78d158bCD59E9eFeDa07b3d89c7A3, sufficientEth);

        // When
        new ActivateProtocol().run();

        //Then
        assertTrue(true, "Protocol activation completed without reverting");
        assertTrue(s_protocolActivator.s_activated());
    }
}
