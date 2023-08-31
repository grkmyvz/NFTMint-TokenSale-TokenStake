// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setSeedsaleStatus is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event ChangedSeedsaleStatus(uint256 _timestamp);

    function test_ShouldBeSuccess_setSeedsaleStatus() public sendTokens {
        vm.warp(10);
        vm.startPrank(users.owner);
        vm.expectEmit(address(tokenSale));
        emit ChangedSeedsaleStatus(10);
        tokenSale.setSeedsaleStatus(true);
        vm.stopPrank();

        assertTrue(tokenSale.seedsaleStatus());
    }

    function test_Revert_OnlyOwner_setSeedsaleStatus() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        tokenSale.setSeedsaleStatus(true);
    }

    function test_Revert_FirstSendTokens_setSeedsaleStatus() public {
        vm.prank(users.owner);
        vm.expectRevert(TokenSale.FirstSendTokens.selector);
        tokenSale.setSeedsaleStatus(true);
    }
}
