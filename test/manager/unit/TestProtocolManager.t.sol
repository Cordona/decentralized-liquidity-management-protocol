// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// External Dependencies
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

// Protocol Contracts & Utils
import {BaseProtocol} from "src/common/BaseProtocol.sol";
import {ProtocolToken} from "src/token/ProtocolToken.sol";
import {ProtocolManager} from "src/manager/ProtocolManager.sol";
import {Roles} from "src/common/Roles.sol";
import {Utils} from "src/common/Utils.sol";

// Test Dependencies
import {BaseTest, console} from "test/base/BaseTest.t.sol";
import {Deploy} from "script/deploy/Deploy.s.sol";
import {ProtocolDeployment} from "script/deploy/DeploymentTypes.s.sol";
import "script/deploy/DeploymentVariables.sol";

contract TestProtocolManager is BaseTest {
    using Utils for uint256;

    // [STATE] |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ProtocolManager private s_manager;
    ProtocolToken private s_protocolToken;

    // [EVENTS] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    event NewAdmin(address indexed admin);
    event NewSupplyRemainderRecipient(address indexed supplyRecipient);

    function setUp() public {
        (ProtocolDeployment memory deployment,) = new Deploy().run();
        s_manager = deployment.core.manager;
        s_protocolToken = deployment.core.token;
    }

    function testShouldRevertInstantiatingProtocolManagerForInvalidAddressInTheConstructor() public {
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new ProtocolManager(ZERO_ADDR, someAddress(), someAddress(), someAddress(), someAddress(), someAddress());

        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new ProtocolManager(someAddress(), ZERO_ADDR, someAddress(), someAddress(), someAddress(), someAddress());

        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new ProtocolManager(someAddress(), someAddress(), ZERO_ADDR, someAddress(), someAddress(), someAddress());

        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new ProtocolManager(someAddress(), someAddress(), someAddress(), ZERO_ADDR, someAddress(), someAddress());

        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new ProtocolManager(someAddress(), someAddress(), someAddress(), someAddress(), ZERO_ADDR, someAddress());

        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        new ProtocolManager(someAddress(), someAddress(), someAddress(), someAddress(), someAddress(), ZERO_ADDR);
    }

    function testShouldSuccessfullyChangeAdmin() public {
        // Given
        address newAdmin = makeAddr("New admin");

        // When
        vm.startPrank(deployer());
        vm.expectEmit(true, false, false, false, address(s_manager));
        emit NewAdmin(newAdmin);
        s_manager.changeAdmin(newAdmin);
        vm.stopPrank();

        vm.startPrank(newAdmin);
        assertEq(s_manager.hasRole(Roles.ADMIN_ROLE), Roles.ADMIN_ROLE);
        vm.stopPrank();

        vm.startPrank(deployer());
        assertEq(s_manager.hasRole(Roles.ADMIN_ROLE), NO_ROLE);
        vm.stopPrank();
    }

    function testShouldRevertChangeAdminForUnauthorizedAccess() public {
        // Given
        address newAdmin = makeAddr("New admin");
        address unauthorizedAddress = makeAddr("Unauthorized address");

        // When/Then
        vm.startPrank(unauthorizedAddress);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, unauthorizedAddress, Roles.ADMIN_ROLE
            )
        );
        s_manager.changeAdmin(newAdmin);
        vm.stopPrank();
    }

    function testShouldRevertChangeAdminForInvalidAccess() public {
        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_manager.changeAdmin(ZERO_ADDR);
        vm.stopPrank();
    }

    function testShouldSuccessfullyChangeSupplyRemainderRecipient() public {
        // Given
        address newRecipient = makeAddr("New supply remainder recipient");

        // When
        vm.startPrank(deployer());
        vm.expectEmit(true, false, false, false, address(s_manager));
        emit NewSupplyRemainderRecipient(newRecipient);
        s_manager.changeSupplyRemainderRecipient(newRecipient);
        vm.stopPrank();

        // Then
        assertEq(s_manager.s_supplyRemainderRecipient(), newRecipient);
    }

    function testShouldRevertChangeSupplyRemainderRecipientForUnauthorizedAccess() public {
        // Given
        address newRecipient = makeAddr("New supply remainder recipient");
        address unauthorizedAddress = makeAddr("Unauthorized address");

        // When/Then
        vm.startPrank(unauthorizedAddress);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, unauthorizedAddress, Roles.ADMIN_ROLE
            )
        );
        s_manager.changeSupplyRemainderRecipient(newRecipient);
        vm.stopPrank();
    }

    function testShouldRevertChangeSupplyRemainderRecipientForInvalidAccess() public {
        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_manager.changeSupplyRemainderRecipient(ZERO_ADDR);
        vm.stopPrank();
    }

    function testShouldTransferProtocolTokenRemainder() public {
        // Given
        uint256 someAmount = 100_000 * 1e18;
        uint256 remainder = s_protocolToken.totalSupply() - someAmount;
        address supplyOwner = deployer();
        // When
        vm.startPrank(deployer());
        s_protocolToken.transfer(someAddress(), someAmount);
        s_protocolToken.approve(address(s_manager), s_protocolToken.balanceOf(supplyOwner));
        s_manager.transferSupplyRemainder(supplyOwner);
        vm.stopPrank();
        // Then
        uint256 recipientBalance = s_protocolToken.balanceOf(s_manager.s_supplyRemainderRecipient());
        assert(recipientBalance == remainder);
    }

    function testShouldRevertTransferProtocolTokenRemainderForUnauthorizedAccess() public {
        // Given
        address supplyOwner = deployer();
        address unauthorizedAddress = someAddress();
        // When/Then
        vm.startPrank(unauthorizedAddress);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, unauthorizedAddress, Roles.ADMIN_ROLE
            )
        );
        s_manager.transferSupplyRemainder(supplyOwner);
        vm.stopPrank();
    }

    function testShouldRevertTransferProtocolTokenRemainderForInvalidAddress() public {
        // When/Then
        vm.startPrank(deployer());
        vm.expectRevert(BaseProtocol.Base__ZeroAddress.selector);
        s_manager.transferSupplyRemainder(ZERO_ADDR);
        vm.stopPrank();
    }
}
