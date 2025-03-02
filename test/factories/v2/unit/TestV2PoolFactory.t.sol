// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Contracts
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";
import {ModuleInitializer} from "src/initializer/ModuleInitializer.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import {Deploy} from "script/deploy/Deploy.s.sol";
import {ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";

contract TestV2PoolFactory is BaseTest {
    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    address private s_protocolActivator;
    UniswapV2PoolFactory private s_factory;

    function setUp() public {
        (ProtocolDeployment memory deployment,) = new Deploy().run();

        s_protocolActivator = address(deployment.periphery.protocolActivator);
        s_factory = deployment.periphery.v2Factory;
    }

    function testShouldRevertForInvalidAddressInTheConstructor() public {
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new UniswapV2PoolFactory(ZERO_ADDR, someAddress(), someAddress());

        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new UniswapV2PoolFactory(someAddress(), ZERO_ADDR, someAddress());

        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new UniswapV2PoolFactory(someAddress(), someAddress(), ZERO_ADDR);
    }

    function testShouldRevertForNotAuthorizedInitializationAttempt() public {
        // When/Then
        vm.startPrank(deployer());
        vm.expectRevert();
        s_factory.initialize("V2 Pool Factory", someAddress());
        vm.stopPrank();
    }

    function testShouldRevertForInvalidNewAdminAddress() public {
        // When/Then
        vm.startPrank(s_protocolActivator);
        vm.expectRevert();
        s_factory.initialize("V2 Pool Factory", ZERO_ADDR);
        vm.stopPrank();
    }

    function testShouldRevertForSecondInitializationAttempt() public {
        // When/Then
        vm.startPrank(s_protocolActivator);
        vm.expectRevert(ModuleInitializer.ModuleInitializer__AlreadyInitialized.selector);
        s_factory.initialize("V2 Pool Factory", someAddress());
        vm.stopPrank();
    }
}
