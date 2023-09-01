// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setPresaleMerkleRoot is BaseSetup {
    bytes32 testPresaleMerkleRoot = keccak256(abi.encodePacked("root"));

    function test_ShouldBeSuccess_setPresaleMerkleRoot() public {
        vm.startPrank(users.owner);
        tokenSale.setPresaleMerkleRoot(testPresaleMerkleRoot);
        vm.stopPrank();
    }

    function test_Revert_OnlyOwner_setPresaleMerkleRoot() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        tokenSale.setPresaleMerkleRoot(testPresaleMerkleRoot);
    }

    function test_Revert_InvalidMerkleProof_setPresaleMerkleRoot() public {
        vm.startPrank(users.owner);
        vm.expectRevert(TokenSale.InvalidMerkleProof.selector);
        tokenSale.setPresaleMerkleRoot(bytes32(0));
        vm.stopPrank();
    }
}
