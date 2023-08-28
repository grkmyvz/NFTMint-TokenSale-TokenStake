// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract publicMint is BaseSetup {
    // Defined in NFTContract.sol (If you change it, you need to change it here too)
    event MintedForPublic(address indexed _to, uint256 _qty);

    function test_ShouldBeSuccess_publicMint() public {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.warp(nftContract.PUBLIC_START());
        vm.prank(users.publicMinter);
        vm.expectEmit(address(nftContract));
        emit MintedForPublic(address(users.publicMinter), publicMintQty);
        nftContract.publicMint{value: publicPrice * publicMintQty}(
            publicMintQty
        );

        assertEq(nftContract.totalSupply(), publicMintQty);
        assertEq(
            nftContract.balanceOf(address(users.publicMinter)),
            publicMintQty
        );
    }

    function test_ShouldBeSuccessIncreaseBalance_publicMint() public {
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.warp(nftContract.PUBLIC_START());
        vm.prank(users.publicMinter);
        nftContract.publicMint{value: publicPrice}(1);

        assertEq(nftContract.balanceOf(address(users.publicMinter)), 1);

        vm.prank(users.publicMinter);
        nftContract.publicMint{value: publicPrice}(1);

        assertEq(nftContract.balanceOf(address(users.publicMinter)), 2);
    }

    function test_Revert_PublicMintNotStarted_publicMint() public {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.PublicMintNotStarted.selector);
        nftContract.publicMint{value: publicPrice * publicMintQty}(
            publicMintQty
        );
    }

    function test_Revert_MintingStopped_publicMint() public {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.warp(nftContract.PUBLIC_START());
        vm.prank(users.owner);
        nftContract.setMintStatus(true);
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.MintingStopped.selector);
        nftContract.publicMint{value: publicPrice * publicMintQty}(
            publicMintQty
        );
    }

    function test_Revert_InvalidAmount_publicMint() public {
        vm.warp(nftContract.PUBLIC_START());
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.publicMint{value: 0}(0);
    }

    function test_Revert_OverflowMaxSupply_publicMint()
        public
        mintedForOwner(nftContract.MAX_SUPPLY() - 1)
    {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.warp(nftContract.PUBLIC_START());
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.OverflowMaxSupply.selector);
        nftContract.publicMint{value: publicPrice * publicMintQty}(
            publicMintQty
        );
    }

    function test_Revert_PublicMintLimitExceeded_publicMint() public {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.warp(nftContract.PUBLIC_START());
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.PublicMintLimitExceeded.selector);
        nftContract.publicMint{value: publicPrice * (publicMintQty + 1)}(
            publicMintQty + 1
        );
    }
}
