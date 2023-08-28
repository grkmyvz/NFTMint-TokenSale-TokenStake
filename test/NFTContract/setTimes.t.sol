// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setTimes is BaseSetup {
    // Defined in NFTContract.sol (If you change it, you need to change it here too)
    event ChangedTimes(
        uint256 _freeStart,
        uint256 _freeStop,
        uint256 _whitelistStart,
        uint256 _whitelistStop,
        uint256 _publicStart
    );

    function test_ShouldBeSuccess_setTimes() public {
        vm.prank(users.owner);
        vm.expectEmit(address(nftContract));
        emit ChangedTimes(2, 4, 6, 8, 10);
        nftContract.setTimes(2, 4, 6, 8, 10);

        assertEq(nftContract.FREE_START(), 2);
        assertEq(nftContract.FREE_STOP(), 4);
        assertEq(nftContract.WHITELIST_START(), 6);
        assertEq(nftContract.WHITELIST_STOP(), 8);
        assertEq(nftContract.PUBLIC_START(), 10);
    }

    function test_Revert_OnlyOwner_setTimes() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.setTimes(2, 4, 6, 8, 10);
    }

    function test_Revert_InvalidFreeMintTime1_setTimes() public {
        vm.warp(4);
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidFreeMintTime.selector);
        nftContract.setTimes(2, 4, 6, 8, 10);
    }

    function test_Revert_InvalidFreeMintTime2_setTimes() public {
        for (uint256 i = 2; i < 4; i++) {
            vm.prank(users.owner);
            vm.expectRevert(NFTName.InvalidFreeMintTime.selector);
            nftContract.setTimes(i, 2, 6, 8, 10);
        }
    }

    function test_Revert_InvalidFreeMintTime3_setTimes() public {
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidFreeMintTime.selector);
        nftContract.setTimes(2, 6, 4, 8, 10);
    }

    function test_Revert_InvalidWhitelistMintTime1_setTimes() public {
        for (uint256 i = 8; i < 10; i++) {
            vm.prank(users.owner);
            vm.expectRevert(NFTName.InvalidWhitelistMintTime.selector);
            nftContract.setTimes(2, 4, i, 8, 10);
        }
    }

    function test_Revert_InvalidWhitelistMintTime2_setTimes() public {
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidWhitelistMintTime.selector);
        nftContract.setTimes(2, 4, 6, 12, 10);
    }
}
