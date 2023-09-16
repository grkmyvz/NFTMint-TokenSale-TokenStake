// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract publicMint is BaseSetup {
    function test_ShouldBeSuccess_publicMint() public activePublicMint {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
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

    function test_ShouldBeSuccessIncreaseBalance_publicMint()
        public
        activePublicMint
    {
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.prank(users.publicMinter);
        nftContract.publicMint{value: publicPrice}(1);

        assertEq(nftContract.balanceOf(address(users.publicMinter)), 1);

        vm.prank(users.publicMinter);
        nftContract.publicMint{value: publicPrice}(1);

        assertEq(nftContract.balanceOf(address(users.publicMinter)), 2);
    }

    function test_Revert_InvalidAmount_publicMint() public activePublicMint {
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.publicMint{value: 0}(0);
    }

    function test_Revert_OverflowMaxSupply_publicMint()
        public
        mintedForOwner(nftContract.MAX_SUPPLY() - 1)
        activePublicMint
    {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.OverflowMaxSupply.selector);
        nftContract.publicMint{value: publicPrice * publicMintQty}(
            publicMintQty
        );
    }

    function test_Revert_PublicMintClosed_publicMint() public {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.PublicMintClosed.selector);
        nftContract.publicMint{value: publicPrice * publicMintQty}(
            publicMintQty
        );
    }

    function test_Revert_PublicMintLimitExceeded_publicMint()
        public
        activePublicMint
    {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.PublicMintLimitExceeded.selector);
        nftContract.publicMint{value: publicPrice * (publicMintQty + 1)}(
            publicMintQty + 1
        );
    }

    function test_Revert_InsufficientBalance_publicMint()
        public
        activePublicMint
    {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();
        vm.prank(users.publicMinter);
        vm.expectRevert(NFTName.InsufficientBalance.selector);
        nftContract.publicMint{value: publicPrice * publicMintQty - 1}(
            publicMintQty
        );
    }
}
