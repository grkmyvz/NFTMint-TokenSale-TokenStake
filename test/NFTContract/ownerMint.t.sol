// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract ownerMint is BaseSetup {
    function test_ShouldBeSuccess_ownerMint() public {
        vm.prank(users.owner);
        nftContract.ownerMint(1);

        assertEq(nftContract.totalSupply(), 1);
        assertEq(nftContract.balanceOf(address(users.owner)), 1);
    }

    function test_Revert_OnlyOwner_ownerMint() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.ownerMint(1);
    }

    function test_Revert_InvalidAmount_ownerMint() public {
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.ownerMint(0);
    }

    function test_Revert_OwerflowMaxSupply_ownerMint() public {
        uint256 overflowSupply = nftContract.MAX_SUPPLY() + 1;
        vm.prank(users.owner);
        vm.expectRevert(NFTName.OverflowMaxSupply.selector);
        nftContract.ownerMint(overflowSupply);
    }
}
