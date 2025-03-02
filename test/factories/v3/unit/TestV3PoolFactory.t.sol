// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Contracts
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {ProtocolManager} from "src/manager/ProtocolManager.sol";
import {UniswapV3PoolFactory} from "src/factories/v3/UniswapV3PoolFactory.sol";
import {ModuleInitializer} from "src/initializer/ModuleInitializer.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import {Deploy} from "script/deploy/Deploy.s.sol";
import {ProtocolDeployment, ProtocolConfig} from "script/deploy/DeploymentTypes.s.sol";
import "script/deploy/DeploymentVariables.sol";

contract TestV3PoolFactory is BaseTest {
    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    address private s_protocolActivator;
    UniswapV3PoolFactory private s_factory;
    address private s_positionManagerAddr;
    address private s_wethAddr;

    function setUp() public {
        (ProtocolDeployment memory deployment, ProtocolConfig memory config) = new Deploy().run();

        s_protocolActivator = address(deployment.periphery.protocolActivator);
        s_factory = deployment.periphery.v3Factory;
        s_positionManagerAddr = config.periphery.uniswapV3.positionManagerAddr;
        s_wethAddr = config.periphery.wethAddr;
    }

    function testShouldRevertForInvalidAddressInTheConstructor() public {
        // Then
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new UniswapV3PoolFactory(ZERO_ADDR, s_wethAddr);

        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new UniswapV3PoolFactory(s_positionManagerAddr, ZERO_ADDR);
    }

    function testShouldRevertForNotAuthorizedInitializationAttempt() public {
        // When/Then
        vm.startPrank(deployer());
        vm.expectRevert();
        s_factory.initialize("V3 Pool Factory", someAddress());
        vm.stopPrank();
    }

    function testShouldRevertForInvalidNewAdminAddress() public {
        // When/Then
        vm.startPrank(s_protocolActivator);
        vm.expectRevert();
        s_factory.initialize("V3 Pool Factory", ZERO_ADDR);
        vm.stopPrank();
    }

    function testShouldRevertForSecondInitializationAttempt() public {
        // When/Then
        vm.startPrank(s_protocolActivator);
        vm.expectRevert(ModuleInitializer.ModuleInitializer__AlreadyInitialized.selector);
        s_factory.initialize("V3 Pool Factory", someAddress());
        vm.stopPrank();
    }
}
