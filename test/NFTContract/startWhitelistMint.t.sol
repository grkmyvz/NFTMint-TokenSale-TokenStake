// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract startWhitelistMint is BaseSetup {
    function test_ShouldBeSuccess_startWhitelistMint() public {
        assertFalse(nftContract.isWhitelistMintStarted());
        vm.warp(123);
        vm.prank(users.owner);
        vm.expectEmit(address(nftContract));
        emit WhitelistMintStarted(123);
        nftContract.startWhitelistMint();

        assertTrue(nftContract.isWhitelistMintStarted());
    }

    function test_Revert_OnlyOwner_startWhitelistMint() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.startWhitelistMint();
    }
}
