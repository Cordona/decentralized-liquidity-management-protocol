// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockPairToken is ERC20 {
    // [CONSTANTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    uint256 private constant TOKEN_SCALE = 1e18;
    uint256 private constant TOTAL_SUPPLY = 300_000_000;

    constructor() ERC20("Test Pair Token", "TPT") {
        _mint(msg.sender, TOTAL_SUPPLY * TOKEN_SCALE);
    }
}
