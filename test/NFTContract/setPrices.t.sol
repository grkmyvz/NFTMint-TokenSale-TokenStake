// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setPrices is BaseSetup {
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

    function test_Revert_InvalidPrice1_setPrice() public {
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidPrice.selector);
        nftContract.setPrices(0, 2 ether);

        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidPrice.selector);
        nftContract.setPrices(1 ether, 0);
    }

    function test_Revert_InvalidPrice2_setPrice() public {
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidPrice.selector);
        nftContract.setPrices(2 ether, 1 ether);
    }

    function test_Revert_CanNotChangePrice1_setPrices() public {
        vm.startPrank(users.owner);
        nftContract.startWhitelistMint();
        vm.expectRevert(NFTName.CanNotChangePrice.selector);
        nftContract.setPrices(1 ether, 2 ether);
    }

    function test_Revert_CanNotChangePrice2_setPrices() public {
        vm.startPrank(users.owner);
        nftContract.startPublicMint();
        vm.expectRevert(NFTName.CanNotChangePrice.selector);
        nftContract.setPrices(1 ether, 2 ether);
    }
}
