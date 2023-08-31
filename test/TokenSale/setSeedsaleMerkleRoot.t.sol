// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setSeedsaleMerkleRoot is BaseSetup {
    bytes32 testSeedsaleMerkleRoot = keccak256(abi.encodePacked("root"));

    function test_ShouldBeSuccess_setSeedsaleMerkleRoot() public {
        vm.startPrank(users.owner);
        tokenSale.setSeedsaleMerkleRoot(testSeedsaleMerkleRoot);
        vm.stopPrank();
    }

    function test_Revert_OnlyOwner_setSeedsaleMerkleRoot() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        tokenSale.setSeedsaleMerkleRoot(testSeedsaleMerkleRoot);
    }

    function test_Revert_InvalidMerkleProof_setSeedsaleMerkleRoot() public {
        vm.startPrank(users.owner);
        vm.expectRevert(TokenSale.InvalidMerkleProof.selector);
        tokenSale.setSeedsaleMerkleRoot(bytes32(0));
        vm.stopPrank();
    }
}
