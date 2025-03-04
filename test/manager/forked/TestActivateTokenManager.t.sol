// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

// Protocol Contracts & Utils
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";
import {ProtocolManager} from "src/manager/ProtocolManager.sol";
import {UniswapV2PoolFactory} from "src/factories/v2/UniswapV2PoolFactory.sol";
import {UniswapV3PoolFactory} from "src/factories/v3/UniswapV3PoolFactory.sol";
import {ProtocolActivator} from "src/activator/ProtocolActivator.sol";
import {Utils} from "src/common/Utils.sol";
import {Roles} from "src/common/Roles.sol";
import {PoolConfig, ActivationScope} from "src/common/Types.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import {Deploy} from "script/deploy/Deploy.s.sol";
import {MockPairToken} from "test/mocks/MockPairToken.sol";
import {ProtocolConfig, ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";
import "script/deploy/DeploymentVariables.sol";

contract TestActivateProtocolManager is BaseTest {
    using Utils for uint256;

    // [CONSTANTS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    uint256 public constant LOCKER_ETH_MAIN_NET_FLAT_FEE = 0.1 ether;

    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ProtocolToken private s_protocolToken;
    MockPairToken private s_pairToken;
    ProtocolManager private s_manager;
    UniswapV2PoolFactory private s_v2Factory;
    UniswapV3PoolFactory private s_v3Factory;
    ProtocolActivator private s_protocolActivator;

    address private s_liquidityTokensRecipient;
    uint256 private s_protocolTokenLiquidity;
    uint256 private s_pairTokenLiquidity;
    uint256 private s_wethLiquidity;
    uint256 private s_sufficientEth;
    uint256 private s_deadline;
    uint24 private s_fee;
    address private s_wethAddr;

    function setUp() public {
        vm.createSelectFork(vm.envString(RPC_URL_ENV_VAR));

        (ProtocolDeployment memory deployment, ProtocolConfig memory config) = new Deploy().run();

        s_protocolToken = deployment.core.token;
        s_manager = deployment.core.manager;
        s_v2Factory = deployment.periphery.v2Factory;
        s_v3Factory = deployment.periphery.v3Factory;
        s_protocolActivator = deployment.periphery.protocolActivator;

        s_liquidityTokensRecipient = someAddress();
        s_protocolTokenLiquidity = TEST_PROTOCOL_TOKEN_LIQUIDITY;
        s_pairTokenLiquidity = TEST_PAIR_TOKEN_LIQUIDITY;
        s_wethLiquidity = TEST_WETH_LIQUIDITY;
        s_deadline = TEST_DEADLINE;
        s_fee = TEST_FEE;
        s_wethAddr = config.periphery.wethAddr;

        vm.prank(deployer());
        s_pairToken = new MockPairToken();

        uint256 scaledProtocolTokenLiquidity = s_protocolTokenLiquidity.safeScale(address(s_protocolToken));
        uint256 scaledPairTokenLiquidity = s_pairTokenLiquidity.safeScale(address(s_pairToken));

        vm.startPrank(deployer());
        s_protocolToken.transfer(address(s_v2Factory), scaledProtocolTokenLiquidity * 2);
        s_pairToken.transfer(address(s_v2Factory), scaledPairTokenLiquidity);
        s_protocolToken.transfer(address(s_v3Factory), scaledProtocolTokenLiquidity * 2);
        s_pairToken.transfer(address(s_v3Factory), scaledPairTokenLiquidity);
        vm.stopPrank();

        s_sufficientEth = (s_wethLiquidity.safeScale(s_wethAddr) * 2) + (LOCKER_ETH_MAIN_NET_FLAT_FEE * 2);
    }

    function testShouldSuccessfullyActivateProtocolManagerWithFullScope() public {
        // Given
        PoolConfig memory config = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: true, lockV2Liquidity: true});

        vm.deal(deployer(), s_sufficientEth);

        // When
        vm.startPrank(deployer());
        s_manager.activate{value: s_sufficientEth}(config, scope);
        vm.stopPrank();

        (address liquidityTokenA,) =
            s_manager.getV2LiquidityDetails(address(s_protocolToken), address(s_pairToken), s_liquidityTokensRecipient);

        (address liquidityTokenB,) =
            s_manager.getV2LiquidityDetails(address(s_protocolToken), s_wethAddr, s_liquidityTokensRecipient);

        (uint256 liquidityTokenC,,) = s_manager.getV3LiquidityDetails(s_liquidityTokensRecipient);

        (uint256 liquidityTokenD,,) = s_manager.getV3LiquidityDetails(s_liquidityTokensRecipient);

        (,,,, uint256 lockIdA,) = s_manager.getLiquidityLockDetails(address(s_protocolActivator), liquidityTokenA);

        (,,,, uint256 lockIdB,) = s_manager.getLiquidityLockDetails(address(s_protocolActivator), liquidityTokenA);

        // Then
        assertEq(s_protocolActivator.s_activated(), true);

        assert(liquidityTokenA != ZERO_ADDR);
        assert(liquidityTokenB != ZERO_ADDR);
        assert(liquidityTokenC != 0);
        assert(liquidityTokenD != 0);
        assert(lockIdA < type(uint256).max);
        assert(lockIdB < type(uint256).max);
    }

    function testShouldSuccessfullyActivateProtocolManagerWithV2PoolsOnly() public {
        // Given
        PoolConfig memory config = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: false, lockV2Liquidity: false});

        uint256 ethTransfer = s_wethLiquidity.safeScale(s_wethAddr) * 1;

        vm.deal(deployer(), ethTransfer);

        // When
        vm.startPrank(deployer());
        s_manager.activate{value: ethTransfer}(config, scope);
        vm.stopPrank();

        (address liquidityTokenA,) =
            s_manager.getV2LiquidityDetails(address(s_protocolToken), address(s_pairToken), s_liquidityTokensRecipient);

        (address liquidityTokenB,) =
            s_manager.getV2LiquidityDetails(address(s_protocolToken), s_wethAddr, s_liquidityTokensRecipient);

        (uint256 liquidityTokenC,,) = s_manager.getV3LiquidityDetails(s_liquidityTokensRecipient);

        (uint256 liquidityTokenD,,) = s_manager.getV3LiquidityDetails(s_liquidityTokensRecipient);

        (,,,, uint256 lockIdA,) = s_manager.getLiquidityLockDetails(address(s_protocolActivator), liquidityTokenA);

        (,,,, uint256 lockIdB,) = s_manager.getLiquidityLockDetails(address(s_protocolActivator), liquidityTokenA);

        // Then
        assertEq(s_protocolActivator.s_activated(), true);

        assert(liquidityTokenA != ZERO_ADDR);
        assert(liquidityTokenB != ZERO_ADDR);
        assert(liquidityTokenC == 0);
        assert(liquidityTokenD == 0);
        assert(lockIdA == type(uint256).max);
        assert(lockIdB == type(uint256).max);
    }

    function testShouldSuccessfullyActivateProtocolManagerWithV2PoolsOnlyAndLiquidityLocking() public {
        // Given
        PoolConfig memory config = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: false, lockV2Liquidity: true});

        uint256 ethTransfer = (s_wethLiquidity.safeScale(s_wethAddr) * 1) + (LOCKER_ETH_MAIN_NET_FLAT_FEE * 2);

        vm.deal(deployer(), ethTransfer);

        // When
        vm.startPrank(deployer());
        s_manager.activate{value: ethTransfer}(config, scope);
        vm.stopPrank();

        (address liquidityTokenA,) =
            s_manager.getV2LiquidityDetails(address(s_protocolToken), address(s_pairToken), s_liquidityTokensRecipient);

        (address liquidityTokenB,) =
            s_manager.getV2LiquidityDetails(address(s_protocolToken), s_wethAddr, s_liquidityTokensRecipient);

        (uint256 liquidityTokenC,,) = s_manager.getV3LiquidityDetails(s_liquidityTokensRecipient);

        (uint256 liquidityTokenD,,) = s_manager.getV3LiquidityDetails(s_liquidityTokensRecipient);

        (,,,, uint256 lockIdA,) = s_manager.getLiquidityLockDetails(address(s_protocolActivator), liquidityTokenA);

        (,,,, uint256 lockIdB,) = s_manager.getLiquidityLockDetails(address(s_protocolActivator), liquidityTokenA);

        // Then
        assertEq(s_protocolActivator.s_activated(), true);

        assert(liquidityTokenA != ZERO_ADDR);
        assert(liquidityTokenB != ZERO_ADDR);
        assert(liquidityTokenC == 0);
        assert(liquidityTokenD == 0);
        assert(lockIdA < type(uint256).max);
        assert(lockIdB < type(uint256).max);
    }

    function testShouldSuccessfullyActivateProtocolManagerWithV3PoolsOnly() public {
        // Given
        PoolConfig memory config = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: false, createV3Pools: true, lockV2Liquidity: false});

        uint256 ethTransfer = s_wethLiquidity.safeScale(s_wethAddr) * 1;

        vm.deal(deployer(), ethTransfer);

        // When
        vm.startPrank(deployer());
        s_manager.activate{value: ethTransfer}(config, scope);
        vm.stopPrank();

        (address liquidityTokenA,) =
            s_manager.getV2LiquidityDetails(address(s_protocolToken), address(s_pairToken), s_liquidityTokensRecipient);

        (address liquidityTokenB,) =
            s_manager.getV2LiquidityDetails(address(s_protocolToken), s_wethAddr, s_liquidityTokensRecipient);

        (uint256 liquidityTokenC,,) = s_manager.getV3LiquidityDetails(s_liquidityTokensRecipient);

        (uint256 liquidityTokenD,,) = s_manager.getV3LiquidityDetails(s_liquidityTokensRecipient);

        (,,,, uint256 lockIdA,) = s_manager.getLiquidityLockDetails(address(s_protocolActivator), liquidityTokenA);

        (,,,, uint256 lockIdB,) = s_manager.getLiquidityLockDetails(address(s_protocolActivator), liquidityTokenA);

        // Then
        assertEq(s_protocolActivator.s_activated(), true);

        assert(liquidityTokenA == ZERO_ADDR);
        assert(liquidityTokenB == ZERO_ADDR);
        assert(liquidityTokenC != 0);
        assert(liquidityTokenD != 0);
        assert(lockIdA == type(uint256).max);
        assert(lockIdB == type(uint256).max);
    }

    function testShouldRevertProtocolManagerActivationForUnauthorizedAccess() public {
        // Given
        address unauthorizedAddress = makeAddr("Unauthorized address");

        PoolConfig memory config = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: true, lockV2Liquidity: true});

        // When/Then
        vm.deal(unauthorizedAddress, s_sufficientEth);
        vm.startPrank(unauthorizedAddress);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, unauthorizedAddress, Roles.ADMIN_ROLE
            )
        );
        s_manager.activate{value: s_sufficientEth}(config, scope);
        vm.stopPrank();
    }

    function testShouldRevertProtocolManagerActivationForSecondActivationAttempt() public {
        // Given
        PoolConfig memory config = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: true, lockV2Liquidity: true});

        vm.deal(deployer(), s_sufficientEth);

        // When
        vm.startPrank(deployer());
        s_manager.activate{value: s_sufficientEth}(config, scope);
        vm.stopPrank();

        vm.deal(deployer(), s_sufficientEth);

        // Then
        vm.startPrank(deployer());
        vm.expectRevert(ProtocolActivator.ProtocolActivator__AlreadyActivated.selector);
        s_manager.activate{value: s_sufficientEth}(config, scope);
        vm.stopPrank();
    }

    function testShouldRevertProtocolManagerActivationForInvalidAddresses() public {
        // Given
        PoolConfig memory withInvalidRecipient = PoolConfig({
            liquidityTokensRecipient: ZERO_ADDR,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        PoolConfig memory withInvalidToken = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: ZERO_ADDR,
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        PoolConfig memory withInvalidPair = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: ZERO_ADDR,
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: true, lockV2Liquidity: true});

        // When
        vm.deal(deployer(), s_sufficientEth);

        // Then
        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_manager.activate{value: s_sufficientEth}(withInvalidRecipient, scope);
        vm.stopPrank();

        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_manager.activate{value: s_sufficientEth}(withInvalidToken, scope);
        vm.stopPrank();

        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_manager.activate{value: s_sufficientEth}(withInvalidPair, scope);
        vm.stopPrank();
    }

    function testShouldRevertProtocolManagerActivationForInvalidDeadline() public {
        // Given
        uint256 validDeadline = 30 minutes;
        uint256 invalidDeadline = 40 minutes;

        PoolConfig memory withInvalidDeadline = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: invalidDeadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: true, lockV2Liquidity: true});

        // When
        vm.deal(deployer(), s_sufficientEth);

        // Then
        vm.startPrank(deployer());
        vm.expectRevert(
            abi.encodeWithSelector(
                ProtocolActivator.ProtocolActivator__DeadlineExceedsThreshold.selector, invalidDeadline, validDeadline
            )
        );
        s_manager.activate{value: s_sufficientEth}(withInvalidDeadline, scope);
        vm.stopPrank();
    }

    function testShouldRevertProtocolManagerActivationForInvalidFeeTier() public {
        // Given
        uint24 invalidFeeTier = 15000;

        PoolConfig memory withInvalidFee = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: invalidFeeTier,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: true, lockV2Liquidity: true});

        // When
        vm.deal(deployer(), s_sufficientEth);

        // Then
        vm.startPrank(deployer());
        vm.expectRevert(
            abi.encodeWithSelector(ProtocolActivator.ProtocolActivator__InvalidFeeTier.selector, invalidFeeTier)
        );
        s_manager.activate{value: s_sufficientEth}(withInvalidFee, scope);
        vm.stopPrank();
    }

    function testShouldRevertProtocolManagerActivationForZeroAmounts() public {
        // Given
        PoolConfig memory withInvalidTokenLiquidity = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: 0,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        PoolConfig memory withInvalidPairLiquidity = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: 0,
            wethLiquidity: s_wethLiquidity
        });

        PoolConfig memory withInvalidWethLiquidity = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: 0
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: true, lockV2Liquidity: true});

        // When
        vm.deal(deployer(), s_sufficientEth);

        // Then
        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroValue.selector);
        s_manager.activate{value: s_sufficientEth}(withInvalidTokenLiquidity, scope);
        vm.stopPrank();

        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroValue.selector);
        s_manager.activate{value: s_sufficientEth}(withInvalidPairLiquidity, scope);
        vm.stopPrank();

        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroValue.selector);
        s_manager.activate{value: s_sufficientEth}(withInvalidWethLiquidity, scope);
        vm.stopPrank();
    }

    function testShouldRevertProtocolManagerActivationForInsufficientEthTransfer() public {
        // Given
        uint256 insufficientEthTransfer = s_sufficientEth - 1 ether;

        PoolConfig memory config = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory scope =
            ActivationScope({createV2Pools: true, createV3Pools: true, lockV2Liquidity: true});

        // When
        vm.deal(deployer(), s_sufficientEth);

        // Then
        vm.startPrank(deployer());
        vm.expectRevert(
            abi.encodeWithSelector(
                ProtocolActivator.ProtocolActivator__InsufficientETHTransfer.selector,
                insufficientEthTransfer.descaleEth(),
                s_sufficientEth.descaleEth()
            )
        );
        s_manager.activate{value: insufficientEthTransfer}(config, scope);
        vm.stopPrank();
    }

    function testShouldRevertProtocolManagerActivationForInvalidScope() public {
        // Given
        PoolConfig memory config = PoolConfig({
            liquidityTokensRecipient: s_liquidityTokensRecipient,
            protocolToken: address(s_protocolToken),
            pairToken: address(s_pairToken),
            weth: s_wethAddr,
            v3PoolFee: s_fee,
            liquidityLockerEthFee: LOCKER_ETH_MAIN_NET_FLAT_FEE,
            deadline: s_deadline,
            protocolTokenLiquidity: s_protocolTokenLiquidity,
            pairTokenLiquidity: s_pairTokenLiquidity,
            wethLiquidity: s_wethLiquidity
        });

        ActivationScope memory noPools =
            ActivationScope({createV2Pools: false, createV3Pools: false, lockV2Liquidity: true});

        vm.deal(deployer(), s_sufficientEth);

        // When
        vm.startPrank(deployer());
        vm.expectRevert(
            abi.encodeWithSelector(
                ProtocolActivator.ProtocolActivator__InvalidScope.selector, "No pools selected for activation"
            )
        );
        s_manager.activate{value: s_sufficientEth}(config, noPools);
        vm.stopPrank();

        ActivationScope memory lockingWithoutV2Pools =
            ActivationScope({createV2Pools: false, createV3Pools: true, lockV2Liquidity: true});

        vm.deal(deployer(), s_sufficientEth);

        // Then
        vm.startPrank(deployer());
        vm.expectRevert(
            abi.encodeWithSelector(
                ProtocolActivator.ProtocolActivator__InvalidScope.selector,
                "Cannot lock v2 liquidity without activating V2 pools"
            )
        );
        s_manager.activate{value: s_sufficientEth}(config, lockingWithoutV2Pools);
        vm.stopPrank();
    }
}
