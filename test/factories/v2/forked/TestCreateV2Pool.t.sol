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
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";

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
    ProtocolActivator private s_activator;
    UniswapV2PoolFactory private s_factory;

    uint256 private s_protocolTokenLiquidity;
    uint256 private s_pairTokenLiquidity;
    uint256 private s_deadline;

    // [EVENTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event V2PoolCreated(
        address indexed protocolToken, address indexed pairToken, address indexed liquidityTokenRecipient
    );

    function setUp() public {
        vm.createSelectFork(vm.envString(RPC_URL_ENV_VAR));

        vm.startBroadcast(deployer());
        s_pairToken = new MockPairToken();
        vm.stopBroadcast();

        (ProtocolDeployment memory deployment,) = new Deploy().run();

        s_protocolToken = deployment.core.token;
        s_activator = deployment.periphery.protocolActivator;
        s_factory = deployment.periphery.v2Factory;

        s_protocolTokenLiquidity = TEST_PROTOCOL_TOKEN_LIQUIDITY;
        s_pairTokenLiquidity = TEST_PAIR_TOKEN_LIQUIDITY;
        s_deadline = TEST_DEADLINE;
    }

    function testShouldSuccessfullyCreateV2Pool() public {
        // Given
        uint256 scaledProtocolTokenLiquidity = s_protocolTokenLiquidity.safeScale(address(s_protocolToken));
        uint256 scaledPairTokenLiquidity = s_pairTokenLiquidity.safeScale(address(s_pairToken));

        // When
        vm.startPrank(deployer());
        s_protocolToken.transfer(address(s_factory), scaledProtocolTokenLiquidity);
        s_pairToken.transfer(address(s_factory), scaledPairTokenLiquidity);
        vm.stopPrank();

        vm.startPrank(address(s_activator));
        vm.expectEmit(true, true, true, false, address(s_factory));
        emit V2PoolCreated(address(s_protocolToken), address(s_pairToken), address(s_activator));
        s_factory.createV2Pool(
            address(s_protocolToken),
            address(s_pairToken),
            address(s_activator),
            s_protocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline
        );
        vm.stopPrank();

        // Then
        (address token0, address token1) = Utils.sortTokenAddresses(address(s_protocolToken), address(s_pairToken));

        address pairAddress = IUniswapV2Factory(UNISWAP_V2_FACTORY_MAIN_NET_ADDR).getPair(token0, address(token1));

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        bool isProtocolToken0 = address(s_protocolToken) < address(s_pairToken);
        uint112 protocolTokenReserve = isProtocolToken0 ? reserve0 : reserve1;
        uint112 pairProtocolTokenReserve = isProtocolToken0 ? reserve1 : reserve0;
        uint256 expectedLPTokens =
            Math.sqrt(uint256(protocolTokenReserve) * uint256(pairProtocolTokenReserve)) - UNISWAP_MINIMUM_LIQUIDITY;

        assertTrue(pairAddress != ZERO_ADDR);
        assertEq(protocolTokenReserve, scaledProtocolTokenLiquidity);
        assertEq(pairProtocolTokenReserve, scaledPairTokenLiquidity);
        assertEq(pair.balanceOf(address(s_activator)), expectedLPTokens);
    }

    function testShouldRevertV2PoolCreationForUnauthorizedAccess() public {
        // When/Then
        vm.startPrank(someAddress());
        vm.expectRevert();
        s_factory.createV2Pool(
            address(s_protocolToken),
            address(s_pairToken),
            address(s_activator),
            s_protocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline
        );
        vm.stopPrank();
    }

    function testShouldRevertV2PoolCreationForInsufficientTokenBalance() public {
        // Given
        uint256 scaledProtocolTokenLiquidity = s_protocolTokenLiquidity.safeScale(address(s_protocolToken));
        uint256 scaledPairTokenLiquidity = s_pairTokenLiquidity.safeScale(address(s_pairToken));
        uint256 insufficientProtocolTokenBalance = scaledProtocolTokenLiquidity - 100_000;

        // When
        vm.startPrank(deployer());
        s_protocolToken.transfer(address(s_factory), insufficientProtocolTokenBalance);
        s_pairToken.transfer(address(s_factory), scaledPairTokenLiquidity);
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
        s_factory.createV2Pool(
            address(s_protocolToken),
            address(s_pairToken),
            address(s_activator),
            s_protocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline
        );
        vm.stopPrank();
    }

    function testShouldRevertV2PoolCreationForInsufficientPairBalance() public {
        // Given
        uint256 scaledProtocolTokenLiquidity = s_protocolTokenLiquidity.safeScale(address(s_protocolToken));
        uint256 scaledPairTokenLiquidity = s_pairTokenLiquidity.safeScale(address(s_pairToken));
        uint256 insufficientPairTokenBalance = scaledPairTokenLiquidity - 100_000;

        // When
        vm.startPrank(deployer());
        s_protocolToken.transfer(address(s_factory), scaledProtocolTokenLiquidity);
        s_pairToken.transfer(address(s_factory), insufficientPairTokenBalance);
        vm.stopPrank();

        // Then
        vm.startPrank(address(s_activator));
        vm.expectRevert(
            abi.encodeWithSelector(
                IPoolFactory.PoolFactory__InsufficientBalance.selector,
                address(s_pairToken),
                insufficientPairTokenBalance,
                scaledPairTokenLiquidity
            )
        );
        s_factory.createV2Pool(
            address(s_protocolToken),
            address(s_pairToken),
            address(s_activator),
            s_protocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline
        );
        vm.stopPrank();
    }

    function testShouldRevertV2PoolCreationForOverflowedTokenLiquidity() public {
        // Given
        uint256 invalidProtocolTokenLiquidity = (type(uint256).max / PROTOCOL_TOKEN_SCALE) + 1;
        // When/Then
        vm.startPrank(address(s_activator));
        vm.expectRevert(abi.encodeWithSelector(Utils.Utils__ScalingOverflow.selector, invalidProtocolTokenLiquidity));
        s_factory.createV2Pool(
            address(s_protocolToken),
            address(s_pairToken),
            address(s_activator),
            invalidProtocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline
        );
        vm.stopPrank();
    }

    function testShouldRevertV2PoolCreationForOverflowedPairTokenLiquidity() public {
        // Given
        uint256 invalidPairTokenLiquidity = (type(uint256).max / PROTOCOL_TOKEN_SCALE) + 1;
        // When/Then
        vm.startPrank(address(s_activator));
        vm.expectRevert(abi.encodeWithSelector(Utils.Utils__ScalingOverflow.selector, invalidPairTokenLiquidity));
        s_factory.createV2Pool(
            address(s_protocolToken),
            address(s_pairToken),
            address(s_activator),
            s_protocolTokenLiquidity,
            invalidPairTokenLiquidity,
            s_deadline
        );
        vm.stopPrank();
    }
}
