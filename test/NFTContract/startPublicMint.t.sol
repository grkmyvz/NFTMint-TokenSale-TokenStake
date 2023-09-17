// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract startPublicMint is BaseSetup {
    function test_ShouldBeSuccess_startPublicMint() public {
        assertFalse(nftContract.isPublicMintStarted());
        vm.warp(123);
        vm.prank(users.owner);
        vm.expectEmit(address(nftContract));
        emit PublicMintStarted(123);
        nftContract.startPublicMint();

        assertTrue(nftContract.isPublicMintStarted());
    }

    function test_Revert_OnlyOwner_startPublicMint() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.startPublicMint();
    }
}
