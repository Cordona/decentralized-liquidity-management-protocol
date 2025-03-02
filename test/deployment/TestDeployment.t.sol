// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Interfaces (Uniswap)
import {IUniswapV2Router02} from "@uniswap/v2-periphery/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/interfaces/IUniswapV2Factory.sol";

// Protocol Interfaces
import {IWETH9} from "src/token/IWETH9.sol";
import {IUniswapV2PoolFactory} from "src/factories/v2/IUniswapV2PoolFactory.sol";
import {IUniswapV3PositionManager} from "src/factories/v3/IUniswapV3PositionManager.sol";
import {IUniswapV3PoolFactory} from "src/factories/v3/IUniswapV3PoolFactory.sol";
import {ILiquidityLocker} from "src/locker/ILiquidityLocker.sol";

// Protocol Contracts
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {ProtocolManager} from "src/manager/ProtocolManager.sol";
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";
import {UniswapV3PoolFactory} from "src/factories/v3/UniswapV3PoolFactory.sol";
import {LiquidityLocker} from "src/locker/LiquidityLocker.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";
import {UNCXUniswapV2Locker} from "src/locker/UNCXUniswapV2Locker.sol";
import {Roles} from "src/common/Roles.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import {Deploy} from "script/deploy/Deploy.s.sol";
import {ProtocolConfig, ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";

contract TestDeployment is BaseTest {
    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ProtocolDeployment private s_deployment;
    ProtocolConfig private s_config;
    ProtocolToken private s_protocolToken;
    ProtocolManager private s_manager;
    UniswapV2PoolFactory private s_v2Factory;
    UniswapV3PoolFactory private s_v3Factory;
    LiquidityLocker private s_liquidityLocker;
    ProtocolActivator private s_protocolActivator;

    function setUp() public {
        (s_deployment, s_config) = new Deploy().run();

        s_protocolToken = s_deployment.core.token;
        s_manager = s_deployment.core.manager;
        s_v2Factory = s_deployment.periphery.v2Factory;
        s_v3Factory = s_deployment.periphery.v3Factory;
        s_liquidityLocker = s_deployment.periphery.liquidityLocker;
        s_protocolActivator = s_deployment.periphery.protocolActivator;
    }

    function testShouldDeploySuccessfully() public {
        _assertCoreDeployment();
        _assertProtocolManagerConnections();
        _assertPeripheryConfiguration();
        _assertInitializationStates();
        _assertRoleConfiguration();
    }

    function _assertCoreDeployment() private {
        // Protocol State
        assertEq(s_protocolToken.name(), s_config.core.name);
        assertEq(s_protocolToken.symbol(), s_config.core.symbol);
        assertEq(s_protocolToken.totalSupply(), s_config.core.totalSupply * PROTOCOL_TOKEN_SCALE);
        assertEq(s_protocolToken.balanceOf(deployer()), s_config.core.totalSupply * PROTOCOL_TOKEN_SCALE);

        // Manager State
        assertEq(s_manager.s_supplyRemainderRecipient(), s_config.core.remainderRecipientAddr);
    }

    function _assertProtocolManagerConnections() private view {
        assert(s_manager.i_protocolToken() == s_protocolToken);
        assert(s_manager.i_liquidityLocker() == ILiquidityLocker(address(s_liquidityLocker)));
        assert(s_manager.i_v2PoolFactory() == IUniswapV2PoolFactory(address(s_v2Factory)));
        assert(s_manager.i_v3PoolFactory() == IUniswapV3PoolFactory(address(s_v3Factory)));
        assert(s_manager.i_protocolActivator() == ProtocolActivator(address(s_protocolActivator)));
    }

    function _assertPeripheryConfiguration() private view {
        // Protocol Activator State
        assertEq(s_protocolActivator.s_activated(), false);
        // Uniswap V2 State
        assert(s_v2Factory.i_v2Factory() == IUniswapV2Factory(s_config.periphery.uniswapV2.factoryAddr));
        assert(s_v2Factory.i_v2Router() == IUniswapV2Router02(s_config.periphery.uniswapV2.routerAddr));
        assert(s_v2Factory.i_wethAddr() == s_config.periphery.wethAddr);
        // Uniswap V3 State
        assert(
            s_v3Factory.i_positionManager()
                == IUniswapV3PositionManager(s_config.periphery.uniswapV3.positionManagerAddr)
        );
        assert(s_v3Factory.i_weth() == IWETH9(s_config.periphery.wethAddr));
        // Locker State
        assert(s_liquidityLocker.i_v2Locker() == UNCXUniswapV2Locker(s_config.periphery.locker.liquidityLockerAddr));
        assert(s_liquidityLocker.i_lockDuration() == s_config.periphery.locker.lockDurationDays);
    }

    function _assertInitializationStates() private view {
        assertEq(s_protocolActivator.isInitialized(), true);
        assertEq(s_v2Factory.isInitialized(), true);
        assertEq(s_v3Factory.isInitialized(), true);
        assertEq(s_liquidityLocker.isInitialized(), true);
    }

    function _assertRoleConfiguration() private {
        // Deployer should be the Protocol Manager Admin
        vm.startPrank(deployer());
        assertEq(s_manager.hasRole(Roles.ADMIN_ROLE), Roles.ADMIN_ROLE);
        vm.stopPrank();
        // Deployer should be the token rescuer
         vm.startPrank(deployer());
        assertEq(s_v2Factory.hasRole(Roles.TOKEN_RESCUER_ROLE), Roles.TOKEN_RESCUER_ROLE);
        assertEq(s_v3Factory.hasRole(Roles.TOKEN_RESCUER_ROLE), Roles.TOKEN_RESCUER_ROLE);
        vm.stopPrank();
        // Deployer should not have have admin role for periphery contracts after deployment
        vm.startPrank(deployer());
        assertEq(s_v2Factory.hasRole(Roles.ADMIN_ROLE), NO_ROLE);
        assertEq(s_v3Factory.hasRole(Roles.ADMIN_ROLE), NO_ROLE);
        assertEq(s_liquidityLocker.hasRole(Roles.ADMIN_ROLE), NO_ROLE);
        assertEq(s_protocolActivator.hasRole(Roles.ADMIN_ROLE), NO_ROLE);
        vm.stopPrank();
        // Protocol Manager should be the Protocol Activator Admin
        vm.startPrank(address(s_manager));
        assertEq(s_protocolActivator.hasRole(Roles.ADMIN_ROLE), Roles.ADMIN_ROLE);
        vm.stopPrank();
        // Protocol Activator should be admin for factories and locker
        vm.startPrank(address(s_protocolActivator));
        assertEq(s_v2Factory.hasRole(Roles.ADMIN_ROLE), Roles.ADMIN_ROLE);
        assertEq(s_v3Factory.hasRole(Roles.ADMIN_ROLE), Roles.ADMIN_ROLE);
        assertEq(s_liquidityLocker.hasRole(Roles.ADMIN_ROLE), Roles.ADMIN_ROLE);
        vm.stopPrank();
    }
}
