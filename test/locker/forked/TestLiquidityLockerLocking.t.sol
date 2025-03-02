// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/interfaces/IUniswapV2Factory.sol";

// Protocol Contracts & Utils
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {Utils} from "src/common/Utils.sol";
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";
import {ProtocolManager} from "src/manager/ProtocolManager.sol";
import {LiquidityLocker} from "src/locker/LiquidityLocker.sol";

// Test Dependencies
import {BaseTest, console} from "test/base/BaseTest.t.sol";
import {Deploy} from "script/deploy/Deploy.s.sol";
import {MockPairToken} from "test/mocks/MockPairToken.sol";
import {ProtocolConfig, ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";
import "script/deploy/DeploymentVariables.sol";

contract TestLiquidityLockerLocking is BaseTest {
    using Utils for uint256;

    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ProtocolToken private s_protocolToken;
    MockPairToken private s_pairToken;
    ProtocolManager private s_manager;
    address private s_protocolActivator;
    UniswapV2PoolFactory private s_factory;
    LiquidityLocker private s_protocolLocker;

    uint256 private s_protocolTokenLiquidity;
    uint256 private s_pairTokenLiquidity;
    uint256 private s_deadline;
    address private s_liquidityTokensRecipient;
    address private s_uncxLockerAddr;

    // [EVENTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event V2LiquidityLocked(
        address indexed lpToken, uint256 indexed amount, address indexed withdrawer, uint256 unlockDate
    );

    function setUp() public {
        vm.createSelectFork(vm.envString(RPC_URL_ENV_VAR));

        (ProtocolDeployment memory deployment, ProtocolConfig memory config) = new Deploy().run();

        s_protocolLocker = deployment.periphery.liquidityLocker;

        vm.startBroadcast(deployer());
        s_pairToken = new MockPairToken();
        vm.stopBroadcast();

        s_protocolToken = deployment.core.token;
        s_manager = deployment.core.manager;
        s_protocolActivator = address(deployment.periphery.protocolActivator);
        s_factory = deployment.periphery.v2Factory;

        s_protocolTokenLiquidity = config.activation.protocolTokenLiquidity;
        s_pairTokenLiquidity = config.activation.pairTokenLiquidity;
        s_deadline = config.activation.deadline;
        s_liquidityTokensRecipient = config.activation.liquidityTokensRecipient;
        s_uncxLockerAddr = config.periphery.locker.liquidityLockerAddr;
    }

    function testShouldSuccessfullyLockV2Liquidity() public {
        // Given
        uint256 scaledProtocolTokenLiquidity = s_protocolTokenLiquidity.safeScale(address(s_protocolToken));
        uint256 scaledPairTokenLiquidity = s_pairTokenLiquidity.safeScale(address(s_pairToken));
        uint256 lockerFlatEthFee = 0.1 ether;
        uint256 lockerLiquidityTokenFeePercent = 10000;
        uint256 lockDuration = s_protocolLocker.i_lockDuration() * 1 days;

        // When
        vm.startPrank(deployer());
        s_protocolToken.transfer(address(s_factory), scaledProtocolTokenLiquidity);
        s_pairToken.transfer(address(s_factory), scaledPairTokenLiquidity);
        vm.stopPrank();

        vm.startPrank(s_protocolActivator);
        (address liquidityToken, uint256 liquidity) = s_factory.createV2Pool(
            address(s_protocolToken),
            address(s_pairToken),
            s_liquidityTokensRecipient,
            s_protocolTokenLiquidity,
            s_pairTokenLiquidity,
            s_deadline
        );
        vm.stopPrank();

        vm.deal(s_protocolActivator, lockerFlatEthFee);

        vm.startPrank(s_liquidityTokensRecipient);
        IERC20(liquidityToken).transfer(address(s_protocolLocker), liquidity);
        vm.stopPrank();

        vm.startPrank(s_protocolActivator);
        vm.expectEmit(true, true, true, false, address(s_protocolLocker));
        emit V2LiquidityLocked(liquidityToken, liquidity, s_liquidityTokensRecipient, lockDuration);

        s_protocolLocker.lockV2Liquidity{value: lockerFlatEthFee}(liquidityToken, liquidity, s_liquidityTokensRecipient);
        vm.stopPrank();

        (, uint256 amount,, uint256 unlockDate,, address owner) =
            s_manager.getLiquidityLockDetails(s_liquidityTokensRecipient, liquidityToken);

        uint256 liquidityAfterLocking = IERC20(liquidityToken).balanceOf(address(s_manager));
        uint256 lockerFees = (liquidity * 100 / lockerLiquidityTokenFeePercent);

        assert(owner == s_liquidityTokensRecipient);
        assert(amount == liquidity - lockerFees);
        assert(liquidityAfterLocking == 0);
        assert(unlockDate - block.timestamp == lockDuration);
    }

    function testShouldRevertLockingLiquidityForUnauthorizedAccess() public {
        // Given
        uint256 someValue = 1 ether;
        // When
        vm.deal(s_protocolActivator, someValue);
        // Then
        vm.startPrank(someAddress());
        vm.expectRevert();
        s_protocolLocker.lockV2Liquidity{value: someValue}(someAddress(), someValue, someAddress());
        vm.stopPrank();
    }

    function testShouldRevertLockingLiquidityForInvalidAddress() public {
        // Given
        uint256 someValue = 1 ether;
        // When
        vm.deal(s_protocolActivator, someValue);
        // Then
        vm.startPrank(s_protocolActivator);
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_protocolLocker.lockV2Liquidity{value: someValue}(ZERO_ADDR, someValue, someAddress());
        vm.stopPrank();

        vm.startPrank(s_protocolActivator);
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_protocolLocker.lockV2Liquidity{value: someValue}(someAddress(), someValue, ZERO_ADDR);
        vm.stopPrank();
    }
}
