// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Interfaces
import {ILiquidityLocker} from "src/locker/ILiquidityLocker.sol";

// Protocol Contracts & Utils
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {LiquidityLocker} from "src/locker/LiquidityLocker.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";

contract TestLiquidityLocker is BaseTest {
    // [CONSTANT] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    uint256 private constant VALID_LOCK_DURATION_DAYS = 365;

    function testShouldRevertInstantiatingLiquidityLockerForInvalidAddressInTheConstructor() public {
        //When/Then
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new LiquidityLocker(ZERO_ADDR, VALID_LOCK_DURATION_DAYS);
    }

    function testShouldRevertInstantiatingLiquidityLockerForInvalidLockDurationInTheConstructor() public {
        uint256 invalidLockDurationDays = 360;

        //When/Then
        vm.expectRevert(
            abi.encodeWithSelector(
                ILiquidityLocker.LiquidityLocker__InvalidLockDuration.selector,
                invalidLockDurationDays,
                VALID_LOCK_DURATION_DAYS
            )
        );
        new LiquidityLocker(someAddress(), invalidLockDurationDays);
    }
}
