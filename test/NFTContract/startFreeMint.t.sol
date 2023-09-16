// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract startFreeMint is BaseSetup {
    function test_ShouldBeSuccess_startFreeMint() public {
        assertFalse(nftContract.isFreeMintStarted());
        vm.warp(123);
        vm.prank(users.owner);
        vm.expectEmit(address(nftContract));
        emit FreeMintStarted(123);
        nftContract.startFreeMint();

        assertTrue(nftContract.isFreeMintStarted());
    }

    function test_Revert_OnlyOwner_startFreeMint() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.startFreeMint();
    }
}
