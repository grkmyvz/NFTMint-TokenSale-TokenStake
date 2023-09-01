// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setAirdropStatus is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event ChangedAirdropStatus(uint256 _timestamp);

    function test_ShouldBeSuccess_setAirdropStatus() public sendTokens {
        vm.warp(10);
        vm.startPrank(users.owner);
        vm.expectEmit(address(tokenSale));
        emit ChangedAirdropStatus(10);
        tokenSale.setAirdropStatus(true);
        vm.stopPrank();

        assertTrue(tokenSale.airdropStatus());
    }

    function test_Revert_OnlyOwner_setAirdropStatus() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        tokenSale.setAirdropStatus(true);
    }

    function test_Revert_FirstSendTokens_setAirdropStatus() public {
        vm.prank(users.owner);
        vm.expectRevert(TokenSale.FirstSendTokens.selector);
        tokenSale.setAirdropStatus(true);
    }
}
