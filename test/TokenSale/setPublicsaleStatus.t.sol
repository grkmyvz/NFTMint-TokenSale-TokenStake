// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setPublicsaleStatus is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event ChangedPublicsaleStatus(uint256 _timestamp);

    function test_ShouldBeSuccess_setPublicsaleStatus() public sendTokens {
        vm.warp(20);
        vm.startPrank(users.owner);
        vm.expectEmit(address(tokenSale));
        emit ChangedPublicsaleStatus(20);
        tokenSale.setPublicsaleStatus(true);
        vm.stopPrank();

        uint256 publicAmount = (tokenSale.AIRDROP_AMOUNT() +
            tokenSale.SEEDSALE_AMOUNT() +
            tokenSale.PRESALE_AMOUNT() +
            tokenSale.PUBLICSALE_AMOUNT());

        assertTrue(tokenSale.publicsaleStatus());
        assertTrue(tokenSale.PUBLICSALE_AMOUNT() == publicAmount);
    }

    function test_Revert_OnlyOwner_setPublicsaleStatus() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        tokenSale.setPublicsaleStatus(true);
    }

    function test_Revert_FirstSendTokens_setPublicsaleStatus() public {
        vm.prank(users.owner);
        vm.expectRevert(TokenSale.FirstSendTokens.selector);
        tokenSale.setPublicsaleStatus(true);
    }
}
