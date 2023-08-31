// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setAirdropMerkleRoot is BaseSetup {
    bytes32 testAirdropMerkleRoot = keccak256(abi.encodePacked("root"));

    function test_ShouldBeSuccess_setAirdropMerkleRoot() public {
        vm.startPrank(users.owner);
        tokenSale.setAirdropMerkleRoot(testAirdropMerkleRoot);
        vm.stopPrank();
    }

    function test_Revert_OnlyOwner_setAirdropMerkleRoot() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        tokenSale.setAirdropMerkleRoot(testAirdropMerkleRoot);
    }

    function test_Revert_InvalidMerkleProof_setAirdropMerkleRoot() public {
        vm.startPrank(users.owner);
        vm.expectRevert(TokenSale.InvalidMerkleProof.selector);
        tokenSale.setAirdropMerkleRoot(bytes32(0));
        vm.stopPrank();
    }
}
