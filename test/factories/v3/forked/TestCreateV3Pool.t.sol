// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IUniswapV3Pool} from "@uniswap/v3-core/interfaces/IUniswapV3Pool.sol";
import {IUniswapV3Factory} from "@uniswap/v3-core/interfaces/IUniswapV3Factory.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Protocol Interfaces
import {IPoolFactory} from "src/factories/IPoolFactory.sol";

// Protocol Contracts & Utils
import {Utils} from "src/common/Utils.sol";
import {TokenParams, PoolConfig} from "src/common/Types.sol";
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";
import {UniswapV3PoolFactory} from "src/factories/v3/UniswapV3PoolFactory.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import {Deploy} from "script/deploy/Deploy.s.sol";
import {MockPairToken} from "test/mocks/MockPairToken.sol";
import {ProtocolConfig, ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";
import "script/deploy/DeploymentVariables.sol";

contract TestCreateV3Pool is BaseTest {
    using Utils for uint256;

    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ProtocolToken private s_protocolToken;
    MockPairToken private s_pairToken;
    ProtocolActivator private s_activator;
    UniswapV3PoolFactory private s_factory;

    address private s_wethAddr;
    address private s_liquidityTokensRecipient;
    uint256 private s_protocolTokenLiquidity;
    uint256 private s_pairTokenLiquidity;
    uint256 private s_deadline;
    uint24 private s_fee;

    // [EVENTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event V3PoolCreated(
        address indexed protocolToken, address indexed pairToken, address indexed liquidityTokenRecipient
    );

    function setUp() public {
        vm.createSelectFork(vm.envString(RPC_URL_ENV_VAR));

        vm.startPrank(deployer());
        s_pairToken = new MockPairToken();
        vm.stopPrank();

        (ProtocolDeployment memory deployment, ProtocolConfig memory config) = new Deploy().run();

        s_protocolToken = deployment.core.token;
        s_activator = deployment.periphery.protocolActivator;
        s_factory = deployment.periphery.v3Factory;

        s_wethAddr = config.periphery.wethAddr;
        s_liquidityTokensRecipient = config.activation.liquidityTokensRecipient;
        s_protocolTokenLiquidity = config.activation.protocolTokenLiquidity;
        s_pairTokenLiquidity = config.activation.pairTokenLiquidity;
        s_deadline = config.activation.deadline;
        s_fee = config.activation.fee;
    }

    function testShouldSuccessfullyCreateV3Pool() public {
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
        emit V3PoolCreated(address(s_protocolToken), address(s_pairToken), address(s_liquidityTokensRecipient));
        s_factory.createV3Pool(
            address(s_protocolToken),
            address(s_pairToken),
            s_liquidityTokensRecipient,
            s_protocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline,
            s_fee
        );
        vm.stopPrank();

        (TokenParams memory token0, TokenParams memory token1) = Utils.buildTokenParams(
            address(s_protocolToken), s_protocolTokenLiquidity, address(s_pairToken), s_pairTokenLiquidity
        );

        IUniswapV3Factory factory = IUniswapV3Factory(UNISWAP_V3_FACTORY_MAIN_NET_ADDR);
        address poolAddr = factory.getPool(token0.addr, token1.addr, s_fee);
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddr);

        assertEq(pool.token0(), token0.addr);
        assertEq(pool.token1(), token1.addr);
        assertEq(pool.fee(), s_fee);

        uint256 poolToken0Balance = IERC20(token0.addr).balanceOf(poolAddr);
        uint256 poolToken1Balance = IERC20(token1.addr).balanceOf(poolAddr);

        assertApproxEqAbs(
            poolToken0Balance,
            token0.scaledLiquidity,
            1e15, // Allow 0.001% difference
            "Token0 balance significantly off"
        );
        assertApproxEqAbs(
            poolToken1Balance,
            token1.scaledLiquidity,
            1e15, // Allow 0.001% difference
            "Token1 balance significantly off"
        );
    }

    function testShouldRevertV3PoolCreationForUnauthorizedAccess() public {
        // When/Then
        vm.startPrank(deployer());
        vm.expectRevert();
        s_factory.createV3Pool(
            address(s_protocolToken),
            address(s_pairToken),
            s_liquidityTokensRecipient,
            s_protocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline,
            s_fee
        );
        vm.stopPrank();
    }

    function testShouldRevertV3PoolCreationForInsufficientTokenBalance() public {
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
        s_factory.createV3Pool(
            address(s_protocolToken),
            address(s_pairToken),
            s_liquidityTokensRecipient,
            s_protocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline,
            s_fee
        );
        vm.stopPrank();
    }

    function testShouldRevertV3PoolCreationForInsufficientPairBalance() public {
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
        s_factory.createV3Pool(
            address(s_protocolToken),
            address(s_pairToken),
            s_liquidityTokensRecipient,
            s_protocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline,
            s_fee
        );
        vm.stopPrank();
    }

    function testShouldRevertV3PoolCreationForOverflowedTokenLiquidity() public {
        // Given
        uint256 invalidProtocolTokenLiquidity = (type(uint256).max / PROTOCOL_TOKEN_SCALE) + 1;

        // When/Then
        vm.startPrank(address(s_activator));
        vm.expectRevert(abi.encodeWithSelector(Utils.Utils__ScalingOverflow.selector, invalidProtocolTokenLiquidity));
        s_factory.createV3Pool(
            address(s_protocolToken),
            address(s_pairToken),
            s_liquidityTokensRecipient,
            invalidProtocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline,
            s_fee
        );
        vm.stopPrank();
    }

    function testShouldRevertV3PoolCreationForOverflowedPairTokenLiquidity() public {
        // Given
        uint256 invalidPairTokenLiquidity = (type(uint256).max / PROTOCOL_TOKEN_SCALE) + 1;

        // When/Then
        vm.startPrank(address(s_activator));
        vm.expectRevert(abi.encodeWithSelector(Utils.Utils__ScalingOverflow.selector, invalidPairTokenLiquidity));
        s_factory.createV3Pool(
            address(s_protocolToken),
            address(s_pairToken),
            s_liquidityTokensRecipient,
            s_protocolTokenLiquidity,
            invalidPairTokenLiquidity,
            s_deadline,
            s_fee
        );
        vm.stopPrank();
    }
}
