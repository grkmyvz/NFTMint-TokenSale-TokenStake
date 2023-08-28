// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract setFreelistRoot is BaseSetup {
    bytes32 freelistRoot = keccak256(abi.encodePacked("root"));

    function test_ShouldBeSuccess_setFreelistRoot() public {
        vm.prank(users.owner);
        nftContract.setFreelistRoot(freelistRoot);

        assertEq(nftContract.freeMerkleRoot(), freelistRoot);
    }

    function test_Revert_OnlyOwner_setFreelistRoot() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.setFreelistRoot(freelistRoot);
    }
}
