// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setPresaleStatus is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event ChangedPresaleStatus(uint256 _timestamp);

    function test_ShouldBeSuccess_setPresaleStatus() public sendTokens {
        vm.warp(10);
        vm.startPrank(users.owner);
        vm.expectEmit(address(tokenSale));
        emit ChangedPresaleStatus(10);
        tokenSale.setPresaleStatus(true);
        vm.stopPrank();

        assertTrue(tokenSale.presaleStatus());
    }

    function test_Revert_OnlyOwner_setPresaleStatus() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        tokenSale.setPresaleStatus(true);
    }

    function test_Revert_FirstSendTokens_setPresaleStatus() public {
        vm.prank(users.owner);
        vm.expectRevert(TokenSale.FirstSendTokens.selector);
        tokenSale.setPresaleStatus(true);
    }
}
