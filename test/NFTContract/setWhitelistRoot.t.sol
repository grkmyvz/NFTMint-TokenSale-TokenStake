// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract setWhitelistRoot is BaseSetup {
    bytes32 whitelistRoot = keccak256(abi.encodePacked("root"));

    function test_ShouldBeSuccess_setWhitelistRoot() public {
        vm.prank(users.owner);
        nftContract.setWhitelistRoot(whitelistRoot);

        assertEq(nftContract.whitelistMerkleRoot(), whitelistRoot);
    }

    function test_Revert_OnlyOwner_setWhitelistRoot() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.setWhitelistRoot(whitelistRoot);
    }
}
