// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IUniswapV2Factory} from "@uniswap/v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/interfaces/IUniswapV2Pair.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

// Protocol Interfaces
import {IPoolFactory} from "src/factories/IPoolFactory.sol";

// Protocol Contracts & Utils
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {Utils} from "src/common/Utils.sol";
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";
import {Roles} from "src/common/Roles.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import {Deploy} from "script/deploy/Deploy.s.sol";
import {MockPairToken} from "test/mocks/MockPairToken.sol";
import {ProtocolConfig, ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";
import "script/deploy/DeploymentVariables.sol";

contract TestCreateV2Pool is BaseTest {
    using Utils for uint256;

    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ProtocolToken private s_protocolToken;
    MockPairToken private s_pairToken;
    UniswapV2PoolFactory private s_factory;

    uint256 private s_protocolTokenLiquidity;
    uint256 private s_pairTokenLiquidity;
    uint256 private s_deadline;

    // [EVENTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event TokensRescued(
        address indexed tokenA, address indexed tokenB, address indexed to, uint256 liquidityA, uint256 liquidityB
    );
    event NewTokensRescuer(address indexed newTokenRescuer);

    function setUp() public {
        vm.createSelectFork(vm.envString(RPC_URL_ENV_VAR));

        vm.startBroadcast(deployer());
        s_pairToken = new MockPairToken();
        vm.stopBroadcast();

        (ProtocolDeployment memory deployment,) = new Deploy().run();

        s_protocolToken = deployment.core.token;
        s_factory = deployment.periphery.v2Factory;

        s_protocolTokenLiquidity = TEST_PROTOCOL_TOKEN_LIQUIDITY;
        s_pairTokenLiquidity = TEST_PAIR_TOKEN_LIQUIDITY;
        s_deadline = TEST_DEADLINE;
    }

    function testShouldSuccessfullyRescueTokens() public {
        // Given
        uint256 scaledProtocolTokenLiquidity = s_protocolTokenLiquidity.safeScale(address(s_protocolToken));
        uint256 scaledPairTokenLiquidity = s_pairTokenLiquidity.safeScale(address(s_pairToken));

        // When
        vm.startPrank(deployer());
        s_protocolToken.transfer(address(s_factory), scaledProtocolTokenLiquidity);
        s_pairToken.transfer(address(s_factory), scaledPairTokenLiquidity);
        vm.stopPrank();

        vm.startPrank(deployer());
        vm.expectEmit(true, true, true, true, address(s_factory));
        emit TokensRescued(
            address(s_protocolToken),
            address(s_pairToken),
            someAddress(),
            scaledProtocolTokenLiquidity,
            scaledPairTokenLiquidity
        );
        s_factory.rescueTokens(address(s_protocolToken), address(s_pairToken), someAddress());
        vm.stopPrank();

        assert(s_protocolToken.balanceOf(address(s_factory)) == 0);
        assert(s_pairToken.balanceOf(address(s_factory)) == 0);

        assert(s_protocolToken.balanceOf(someAddress()) == scaledProtocolTokenLiquidity);
        assert(s_pairToken.balanceOf(someAddress()) == scaledPairTokenLiquidity);
    }

    function testShouldFailRescueTokensForUnauthorizedAccess() public {
        // When/Then
        vm.startPrank(someAddress());
        vm.expectRevert();
        s_factory.rescueTokens(address(s_protocolToken), address(s_pairToken), someAddress());
        vm.stopPrank();
    }

    function testShouldFailRescueTokensForInvalidAddresses() public {
        // When/Then
        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_factory.rescueTokens(ZERO_ADDR, address(s_pairToken), someAddress());
        vm.stopPrank();

        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_factory.rescueTokens(address(s_protocolToken), ZERO_ADDR, someAddress());
        vm.stopPrank();

        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_factory.rescueTokens(address(s_protocolToken), address(s_pairToken), ZERO_ADDR);
        vm.stopPrank();
    }

    function testShouldSuccessfullyChangeTokenRescuer() public {
        // When/Then
        vm.startPrank(deployer());
        vm.expectEmit(true, false, false, false, address(s_factory));
        emit NewTokensRescuer(someAddress());
        s_factory.changeRescuer(someAddress());
        vm.stopPrank();

        vm.startPrank(someAddress());
        assertEq(s_factory.hasRole(Roles.TOKEN_RESCUER_ROLE, someAddress()), true);
        assertEq(s_factory.hasRole(Roles.TOKEN_RESCUER_ROLE, someAddress()), true);
        vm.stopPrank();

        vm.startPrank(deployer());
        assertEq(s_factory.hasRole(Roles.TOKEN_RESCUER_ROLE, deployer()), false);
        assertEq(s_factory.hasRole(Roles.TOKEN_RESCUER_ROLE, deployer()), false);
        vm.stopPrank();
    }

    function testShouldFailChangeTokenRescuerForUnauthorizedAccess() public {
        // When/Then
        vm.startPrank(someAddress());
        vm.expectRevert();
        s_factory.changeRescuer(someAddress());
        vm.stopPrank();
    }

    function testShouldFailTokenRescuerForInvalidAddresses() public {
        // When/Then
        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_factory.changeRescuer(ZERO_ADDR);
        vm.stopPrank();
    }
}
