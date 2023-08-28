// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract setMintStatus is BaseSetup {
    // Defined in NFTContract.sol (If you change it, you need to change it here too)
    event ChangedMintStatus(bool _status);

    function test_ShouldBeSuccess_setMintStatus() public {
        vm.prank(users.owner);
        vm.expectEmit(address(nftContract));
        emit ChangedMintStatus(true);
        nftContract.setMintStatus(true);

        assertTrue(nftContract.MINT_STATUS());

        vm.warp(6);
        vm.prank(users.owner);
        vm.expectEmit(address(nftContract));
        emit ChangedMintStatus(false);
        nftContract.setMintStatus(false);

        assertFalse(nftContract.MINT_STATUS());
    }

    function test_Revert_OnlyOwner_setMintStatus() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.setMintStatus(true);
    }
}
