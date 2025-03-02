// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Protocol Contracts
import {BaseProtocol} from "src/common/BaseProtocol.sol";

/**
 * @title Protocol Token Implementation
 * @author foreshadow.xyz | cordona.tech
 * @notice ERC20 token powering the protocol's liquidity infrastructure
 * @dev Extends standard ERC20 with protocol-specific validation and scaling.
 *      This token functions as the primary asset in the protocol's liquidity pairs,
 *      being deployed alongside the core protocol infrastructure.
 *
 *      Key implementation details:
 *      - Total supply is scaled by 10^18 (TOKEN_SCALE) for proper decimal precision
 *      - Input validation prevents empty strings for name/symbol
 *      - Inherits BaseProtocol for core security features
 *
 *      Integration points:
 *      - Used in Uniswap V2/V3 pool creation through factory contracts
 *      - Total supply managed by protocol deployer initially
 *      - Remainder handling through ProtocolManager
 *
 * @custom:security-contact web3.security@cordona.tech
 */
contract ProtocolToken is ERC20, BaseProtocol {
    // [CONSTANTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    uint256 private constant TOKEN_SCALE = 1e18;

    // [ERRORS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    error ProtocolToken__InvalidString(string text);

    // [MODIFIERS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    modifier validString(string memory subject) {
        if (bytes(subject).length == 0) {
            revert ProtocolToken__InvalidString(subject);
        }
        _;
    }

    // [CONSTRUCTOR] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    constructor(string memory name, string memory symbol, uint256 totalSupply)
        ERC20(name, symbol)
        validString(name)
        validString(symbol)
        positiveValue(totalSupply)
    {
        _mint(msg.sender, totalSupply * TOKEN_SCALE);
    }
}
