// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Protocol Contracts
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {Roles} from "src/common/Roles.sol";

/**
 * @title Emergency Token Recovery System
 * @author foreshadow.xyz | cordona.tech
 * @notice Critical recovery mechanism for stuck tokens in protocol contracts
 * @dev Implements the protocol's emergency recovery architecture:
 *
 *      Security architecture:
 *      - Assigns TOKEN_RESCUER_ROLE to the deployer initially
 *      - Maintains separation from operational roles (ADMIN_ROLE)
 *      - Provides last-resort recovery for tokens trapped in contracts
 *      - Enables rescue role transition with proper authorization
 *
 *      This component represents a security contingency that:
 *      - Operates outside normal protocol functionality
 *      - Requires special privileges (TOKEN_RESCUER_ROLE)
 *      - Works with any ERC20-compatible token
 *      - Maintains event emission for transparency and auditability
 *
 * @custom:security-contact web3.security@cordona.tech
 */
abstract contract TokenRescuer is BaseProtocol {
    using SafeERC20 for IERC20;

    // [EVENTS] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event TokensRescued(
        address indexed tokenA, address indexed tokenB, address indexed to, uint256 liquidityA, uint256 liquidityB
    );

    event NewTokensRescuer(address indexed newTokenRescuer);

    // [CONSTRUCTOR] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    constructor() {
        _grantRole(Roles.TOKEN_RESCUER_ROLE, msg.sender);
    }

    // [EXTERNAL] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    /// @notice Recovers stuck tokens from the contract in emergency situations
    /// @dev Emergency Recovery Operation:
    ///      - Restricted to TOKEN_RESCUER_ROLE only
    ///      - Transfers entire balance of both tokens
    ///      - Emits detailed event for auditability
    ///      - Uses SafeERC20 for protected transfers
    ///
    /// @param tokenA First token to rescue
    /// @param tokenB Second token to rescue
    /// @param to Destination address for recovered tokens
    function rescueTokens(address tokenA, address tokenB, address to)
        external
        virtual
        onlyRole(Roles.TOKEN_RESCUER_ROLE)
        validAddress(tokenA)
        validAddress(tokenB)
        validAddress(to)
    {
        uint256 rescuedTokenBalanceA = IERC20(tokenA).balanceOf(address(this));
        uint256 rescuedTokenBalanceB = IERC20(tokenB).balanceOf(address(this));

        emit TokensRescued(tokenA, tokenB, to, rescuedTokenBalanceA, rescuedTokenBalanceB);

        IERC20(tokenA).safeTransfer(to, rescuedTokenBalanceA);
        IERC20(tokenB).safeTransfer(to, rescuedTokenBalanceB);
    }

    /// @notice Transfers token rescue privileges to a new address
    /// @dev Secure Privilege Transition:
    ///      - Restricted to current TOKEN_RESCUER_ROLE holder
    ///      - One-way transfer pattern (grants then revokes)
    ///      - Emits event for auditability
    ///
    /// @param newRescuer Address to receive TOKEN_RESCUER_ROLE
    function changeRescuer(address newRescuer) external onlyRole(Roles.TOKEN_RESCUER_ROLE) validAddress(newRescuer) {
        grantRole(Roles.TOKEN_RESCUER_ROLE, newRescuer);
        revokeRole(Roles.TOKEN_RESCUER_ROLE, msg.sender);
        emit NewTokensRescuer(newRescuer);
    }
}
