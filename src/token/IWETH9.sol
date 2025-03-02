// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title WETH9 Wrapper Interface
 * @author foreshadow.xyz | cordona.tech
 * @notice Standard interface for interacting with Wrapped Ether (WETH9) contract
 * @dev Compatibility layer for Uniswap V3 integration, adapted from Uniswap V3 Periphery (v0.7.6)
 *      to Solidity 0.8.28 for our protocol. This interface enables ETH-to-WETH conversion
 *      required for Uniswap V3 liquidity operations.
 *
 *      Integration points:
 *      - UniswapV3PoolFactory uses this during createV3WethPool() operations
 *      - Enables protocol to deploy Token-ETH pools without token conversion burden for users
 *      - Maintains compatibility with Uniswap's expected WETH interface
 *
 * @custom:security-contact web3.security@cordona.tech
 */
interface IWETH9 is IERC20 {
    function deposit() external payable;
}
