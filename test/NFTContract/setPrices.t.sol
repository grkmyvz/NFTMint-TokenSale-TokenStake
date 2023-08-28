// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setPrices is BaseSetup {
    // Defined in NFTContract.sol (If you change it, you need to change it here too)
    event ChangedPrices(uint256 _whitelistPrice, uint256 _publicPrice);

    function test_ShouldBeSuccess_setPrices() public {
        vm.prank(users.owner);
        vm.expectEmit(address(nftContract));
        emit ChangedPrices(1 ether, 2 ether);
        nftContract.setPrices(1 ether, 2 ether);

        assertEq(nftContract.WHITELIST_PRICE(), 1 ether);
        assertEq(nftContract.PUBLIC_PRICE(), 2 ether);
    }

    function test_Revert_OnlyOwner_setPrices() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.setPrices(1 ether, 2 ether);
    }

    function test_Revert_CanNotChangePrice_setPrices() public {
        vm.warp(6);
        vm.prank(users.owner);
        vm.expectRevert(NFTName.CanNotChangePrice.selector);
        nftContract.setPrices(1 ether, 2 ether);
    }
}
