// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Protocol Contracts
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {BaseProtocol} from "src/common/BaseProtocol.sol";

// Test Dependencies
import {BaseTest} from "test/base/BaseTest.t.sol";
import "script/deploy/DeploymentVariables.sol";

contract TestProtocolToken is BaseTest {
    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    string private s_protocolTokenName;
    string private s_protocolTokenSymbol;
    uint256 private s_protocolTokenTotalSupply;

    function setUp() public {
        s_protocolTokenName = vm.envString(TOKEN_NAME_ENV_VAR);
        s_protocolTokenSymbol = vm.envString(TOKEN_SYMBOL_ENV_VAR);
        s_protocolTokenTotalSupply = vm.envUint(TOKEN_TOTAL_SUPPLY_ENV_VAR);
    }

    function testShouldSuccessfullyInitializeToken() public {
        // Given
        address testDeployer = deployer();
        // When
        vm.startPrank(testDeployer);
        ProtocolToken subject =
            new ProtocolToken(s_protocolTokenName, s_protocolTokenSymbol, s_protocolTokenTotalSupply);
        vm.stopPrank();
        // Then
        assertEq(subject.totalSupply(), s_protocolTokenTotalSupply * PROTOCOL_TOKEN_SCALE);
        assertEq(subject.balanceOf(testDeployer), s_protocolTokenTotalSupply * PROTOCOL_TOKEN_SCALE);
    }

    function testShouldRevertForEmptyName() public {
        // Given
        string memory emptyName = "";
        // When/Then
        vm.expectRevert(abi.encodeWithSelector(ProtocolToken.ProtocolToken__InvalidString.selector, emptyName));
        new ProtocolToken(emptyName, s_protocolTokenSymbol, s_protocolTokenTotalSupply);
    }

    function testShouldRevertForEmptySymbol() public {
        // Given
        string memory emptySymbol = "";
        // When/Then
        vm.expectRevert(abi.encodeWithSelector(ProtocolToken.ProtocolToken__InvalidString.selector, emptySymbol));
        new ProtocolToken(s_protocolTokenName, emptySymbol, s_protocolTokenTotalSupply);
    }

    function testShouldRevertForInvalidSupply() public {
        // Given
        uint256 invalidSupply = 0;
        // When/Then
        vm.expectRevert(BaseProtocol.Base__ZeroValue.selector);
        new ProtocolToken(s_protocolTokenName, s_protocolTokenSymbol, invalidSupply);
    }
}
