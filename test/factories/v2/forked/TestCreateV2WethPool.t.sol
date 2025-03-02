// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IUniswapV2Factory} from "@uniswap/v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/interfaces/IUniswapV2Pair.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

// Protocol Interfaces
import {IPoolFactory} from "src/factories/IPoolFactory.sol";

// Protocol Contracts & Utils
import {Utils} from "src/common/Utils.sol";
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import {Deploy} from "script/deploy/Deploy.s.sol";
import {ProtocolConfig, ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";
import "script/deploy/DeploymentVariables.sol";

contract TestCreateV2WethPool is BaseTest {
    using Utils for uint256;

    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ProtocolToken private s_protocolToken;
    ProtocolActivator private s_activator;
    UniswapV2PoolFactory private s_factory;

    uint256 private s_protocolTokenLiquidity;
    uint256 private s_wethLiquidity;
    uint256 private s_deadline;
    address private s_wethAddr;

    // [EVENTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event V2PoolCreated(
        address indexed protocolToken, address indexed pairToken, address indexed liquidityTokenRecipient
    );

    function setUp() public {
        vm.createSelectFork(vm.envString(RPC_URL_ENV_VAR));

        (ProtocolDeployment memory deployment, ProtocolConfig memory config) = new Deploy().run();

        s_protocolToken = deployment.core.token;
        s_activator = deployment.periphery.protocolActivator;
        s_factory = deployment.periphery.v2Factory;

        s_protocolTokenLiquidity = config.activation.protocolTokenLiquidity;
        s_wethLiquidity = config.activation.wethLiquidity;
        s_deadline = config.activation.deadline;
        s_wethAddr = config.periphery.wethAddr;
    }

    function testShouldSuccessfullyCreateV2WethPool() public {
        // Given
        uint256 scaledWethLiquidity = s_wethLiquidity.safeScale(s_wethAddr);
        uint256 scaledProtocolTokenLiquidity = s_protocolTokenLiquidity.safeScale(address(s_protocolToken));

        // When
        vm.deal(address(s_activator), scaledWethLiquidity);
        vm.startPrank(deployer());
        s_protocolToken.transfer(address(s_factory), scaledProtocolTokenLiquidity);
        vm.stopPrank();

        vm.startPrank(address(s_activator));
        vm.expectEmit(true, true, true, false, address(s_factory));
        emit V2PoolCreated(address(s_protocolToken), address(s_wethAddr), address(s_activator));
        s_factory.createV2WethPool{value: scaledWethLiquidity}(
            address(s_protocolToken), address(s_activator), s_protocolTokenLiquidity, s_deadline
        );
        vm.stopPrank();

        (address token0, address token1) = Utils.sortTokenAddresses(address(s_protocolToken), s_wethAddr);

        // Then
        address pairAddress = IUniswapV2Factory(UNISWAP_V2_FACTORY_MAIN_NET_ADDR).getPair(token0, token1);

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        bool isProtocolToken0 = address(s_protocolToken) < s_wethAddr;
        uint112 protocolTokenReserve = isProtocolToken0 ? reserve0 : reserve1;
        uint112 wethReserve = isProtocolToken0 ? reserve1 : reserve0;
        uint256 expectedLPTokens =
            Math.sqrt(uint256(protocolTokenReserve) * uint256(wethReserve)) - UNISWAP_MINIMUM_LIQUIDITY;

        assertTrue(pairAddress != ZERO_ADDR);
        assertEq(protocolTokenReserve, scaledProtocolTokenLiquidity);
        assertEq(wethReserve, scaledWethLiquidity);
        assertEq(pair.balanceOf(address(s_activator)), expectedLPTokens);
    }

    function testShouldRevertV2WethPoolCreationForUnauthorizedAccess() public {
        // Given
        uint256 scaledWethLiquidity = s_wethLiquidity.safeScale(s_wethAddr);

        // When/Then
        vm.startPrank(someAddress());
        vm.expectRevert();
        s_factory.createV2WethPool{value: scaledWethLiquidity}(
            address(s_protocolToken), address(s_activator), s_protocolTokenLiquidity, s_deadline
        );
        vm.stopPrank();
    }

    function testShouldRevertV2WethPoolCreationForInsufficientTokenBalance() public {
        // Given
        uint256 scaledWethLiquidity = s_wethLiquidity.safeScale(s_wethAddr);
        uint256 scaledProtocolTokenLiquidity = s_protocolTokenLiquidity.safeScale(address(s_protocolToken));
        uint256 insufficientProtocolTokenBalance = scaledProtocolTokenLiquidity - 100_000;

        // When
        vm.deal(address(s_activator), scaledWethLiquidity);
        vm.startPrank(deployer());
        s_protocolToken.transfer(address(s_factory), insufficientProtocolTokenBalance);
        vm.stopPrank();

        // Then
        vm.startPrank(address(s_activator));
        vm.expectRevert(
            abi.encodeWithSelector(
                IPoolFactory.PoolFactory__InsufficientBalance.selector,
                address(s_protocolToken),
                insufficientProtocolTokenBalance,
                scaledProtocolTokenLiquidity
            )
        );
        s_factory.createV2WethPool{value: scaledWethLiquidity}(
            address(s_protocolToken), address(s_activator), s_protocolTokenLiquidity, s_deadline
        );
        vm.stopPrank();
    }

    function testShouldRevertV2WethPoolCreationForOverflowedTokenLiquidity() public {
        // Given
        uint256 scaledWethLiquidity = s_wethLiquidity.safeScale(s_wethAddr);
        uint256 invalidProtocolTokenLiquidity = (type(uint256).max / PROTOCOL_TOKEN_SCALE) + 1;

        // When/Then
        vm.deal(address(s_activator), scaledWethLiquidity);
        vm.startPrank(address(s_activator));
        vm.expectRevert(abi.encodeWithSelector(Utils.Utils__ScalingOverflow.selector, invalidProtocolTokenLiquidity));
        s_factory.createV2WethPool{value: scaledWethLiquidity}(
            address(s_protocolToken), address(s_activator), invalidProtocolTokenLiquidity, s_deadline
        );
        vm.stopPrank();
    }
}
