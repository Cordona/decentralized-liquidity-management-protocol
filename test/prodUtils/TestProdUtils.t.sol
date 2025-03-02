// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

// Protocol Utils & Types
import {Utils} from "src/common/Utils.sol";
import {TokenParams} from "src/common/Types.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import {MockPairToken} from "test/mocks/MockPairToken.sol";
import {MockUSDC} from "test/mocks/MockUSDC.sol";
import {ProtocolConfig, ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";

contract TestProdUtils is BaseTest {
    using Utils for uint256;

    // [CONSTANTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    uint256 private constant AMOUNT_A = 100_000_000;
    uint256 private constant AMOUNT_B = 200_000_000;
    uint256 private constant EIGHTEEN_DECIMAL_SCALE = 1e18;
    uint256 private constant SIX_DECIMAL_SCALE = 1e6;

    function testShouldSuccessfullyDescaleEth() public pure {
        // Given
        uint256 scaledEth = 100 ether;
        // When
        uint256 result = scaledEth.descaleEth();
        // Then
        assert(result == 100);
    }

    function testShouldSuccessfullyScaleLiquidity() public {
        // Given
        MockPairToken tokenA = new MockPairToken();
        MockUSDC tokenB = new MockUSDC();

        // When
        uint256 scaledAmountA = AMOUNT_A.safeScale(address(tokenA));
        uint256 scaledAmountB = AMOUNT_B.safeScale(address(tokenB));

        // Then
        assert(scaledAmountA == AMOUNT_A * EIGHTEEN_DECIMAL_SCALE);
        assert(scaledAmountB == AMOUNT_B * SIX_DECIMAL_SCALE);
    }

    function testShouldSuccessfullySortAddresses() public {
        // Given
        MockPairToken tokenA = new MockPairToken();
        MockUSDC tokenB = new MockUSDC();

        // When
        (address token0, address token1) = Utils.sortTokenAddresses(address(tokenA), address(tokenB));

        // Then
        if (address(tokenA) < address(tokenB)) {
            assertEq(token0, address(tokenA));
            assertEq(token1, address(tokenB));
        } else {
            assertEq(token0, address(tokenB));
            assertEq(token1, address(tokenA));
        }

        assertTrue(token0 < token1);
    }

    function testShouldRevertWhenAddressesAreIdentical() public {
        // Given
        MockPairToken token = new MockPairToken();

        // When / Then
        vm.expectRevert(Utils.Utils__IdenticalAddresses.selector);
        Utils.sortTokenAddresses(address(token), address(token));
    }

    function testShouldSuccessfullyBuildTokenParams() public {
        // Given
        MockPairToken tokenA = new MockPairToken();
        MockUSDC tokenB = new MockUSDC();

        // When - Case 1: tokenA address < tokenB address
        if (address(tokenA) < address(tokenB)) {
            (TokenParams memory token0, TokenParams memory token1) =
                Utils.buildTokenParams(address(tokenA), AMOUNT_A, address(tokenB), AMOUNT_B);

            // Then
            assert(token0.addr == address(tokenA));
            assert(token1.addr == address(tokenB));
            assert(token0.scaledLiquidity == AMOUNT_A * EIGHTEEN_DECIMAL_SCALE);
            assert(token1.scaledLiquidity == AMOUNT_B * SIX_DECIMAL_SCALE);
        } else {
            // When - Case 2: tokenA address > tokenB address
            (TokenParams memory token0, TokenParams memory token1) =
                Utils.buildTokenParams(address(tokenA), AMOUNT_A, address(tokenB), AMOUNT_B);

            // Then
            assert(token0.addr == address(tokenB));
            assert(token1.addr == address(tokenA));
            assert(token0.scaledLiquidity == AMOUNT_B * SIX_DECIMAL_SCALE);
            assert(token1.scaledLiquidity == AMOUNT_A * EIGHTEEN_DECIMAL_SCALE);
        }
    }

    function testShouldCalculateSqrtX96PriceForVariousScenarios() public pure {
        // Scenario 1: Equal Small Amounts (1:1 ratio)
        // Testing with 1000 tokens each
        uint256 smallAmount = 1000 * 1e18;
        uint160 price1 = Utils.sqrtX96Price(smallAmount, smallAmount);
        assertApproxEqRel(
            uint256(price1),
            uint256(1 << 96),
            1e12, // 0.0001% tolerance
            "Equal small amounts should result in 2^96"
        );

        // Scenario 2: Equal Large Amounts (1:1 ratio)
        // Testing with 1 million tokens each
        uint256 largeAmount = 1_000_000 * 1e18;
        uint160 price2 = Utils.sqrtX96Price(largeAmount, largeAmount);
        assertEq(uint256(price2), uint256(price1), "Scale shouldn't affect 1:1 ratio price");

        // Scenario 3: 2:1 ratio (token1 worth twice token0)
        uint160 price3 = Utils.sqrtX96Price(smallAmount, smallAmount * 2);
        uint256 expectedPrice3 = uint256(1 << 96) * 1414213562373095048 / 1000000000000000000;
        assertApproxEqRel(uint256(price3), expectedPrice3, 1e12, "2:1 ratio should result in sqrt(2) * 2^96");

        // Scenario 4: 1:2 ratio (token0 worth twice token1)
        uint160 price4 = Utils.sqrtX96Price(smallAmount * 2, smallAmount);
        uint256 expectedPrice4 = uint256(1 << 96) * 707106781186547524 / 1000000000000000000;
        assertApproxEqRel(uint256(price4), expectedPrice4, 1e12, "1:2 ratio should result in 1/sqrt(2) * 2^96");

        // Scenario 5: 10:1 ratio (token1 worth 10x token0)
        uint160 price5 = Utils.sqrtX96Price(smallAmount, smallAmount * 10);
        uint256 expectedPrice5 = uint256(1 << 96) * 3162277660168379332 / 1000000000000000000;
        assertApproxEqRel(uint256(price5), expectedPrice5, 1e12, "10:1 ratio should result in sqrt(10) * 2^96");

        // Scenario 6: Different decimal scales
        uint256 amount1 = 1234567 * 1e18;
        uint256 amount2 = 7654321 * 1e18;
        uint160 price6 = Utils.sqrtX96Price(amount1, amount2);
        uint256 ratioX96 = (amount2 * (1 << 96)) / amount1;
        uint256 expectedPrice6 = uint256(uint160(Math.sqrt(ratioX96) * (1 << 48)));

        assertApproxEqRel(
            uint256(price6),
            expectedPrice6,
            1e14, // 0.01% tolerance
            "Complex ratio calculation incorrect"
        );
    }
}
