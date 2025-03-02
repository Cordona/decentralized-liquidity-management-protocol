// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Contracts & Utils
import {Test, console} from "lib/forge-std/src/Test.sol";

contract BaseTest is Test {
    // [CONSTANT] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    uint256 internal constant PROTOCOL_TOKEN_SCALE = 1e18;
    uint256 internal constant UNISWAP_MINIMUM_LIQUIDITY = 1000;
    // TODO: Replace with config values
    address internal constant UNISWAP_V2_FACTORY_MAIN_NET_ADDR = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address internal constant UNISWAP_V3_FACTORY_MAIN_NET_ADDR = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address internal constant ZERO_ADDR = address(0);
    bytes32 internal constant NO_ROLE = bytes32(0);

    function deployer() internal returns (address) {
        return makeAddr("Token Manager Admin");
    }

    function someAddress() internal returns (address) {
        return makeAddr("Test address");
    }

    function supplyRecipient() internal returns (address) {
        return makeAddr("Supply Remainder Recipient");
    }

    function liquidityRecipient() internal returns (address) {
        return makeAddr("Liquidity Tokens Recipient");
    }
}
