// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract whitelistMint is BaseSetup {
    bytes32[] public whitelistMinterProof = [
        bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        )
    ];

    function test_ShouldBeSuccess_whitelistMint()
        public
        activeWhitelistRoot
        activeWhitelistMint
    {
        uint256 whitelistMintQty = nftContract.WHITELIST_PER_WALLET();
        uint256 whitelistPrice = nftContract.WHITELIST_PRICE();
        vm.prank(users.whitelistMinter);
        vm.expectEmit(address(nftContract));
        emit MintedForWhitelist(
            address(users.whitelistMinter),
            whitelistMintQty
        );
        nftContract.whitelistMint{value: whitelistPrice * whitelistMintQty}(
            whitelistMinterProof,
            whitelistMintQty
        );

        assertEq(nftContract.totalSupply(), whitelistMintQty);
        assertEq(
            nftContract.balanceOf(address(users.whitelistMinter)),
            whitelistMintQty
        );
    }

    function test_ShouldBeSuccessIncreaseBalance_whitelistMint()
        public
        activeWhitelistRoot
        activeWhitelistMint
    {
        uint256 whitelistPrice = nftContract.WHITELIST_PRICE();
        vm.prank(users.whitelistMinter);
        nftContract.whitelistMint{value: whitelistPrice}(
            whitelistMinterProof,
            1
        );

        assertEq(nftContract.balanceOf(address(users.whitelistMinter)), 1);

        vm.prank(users.whitelistMinter);
        nftContract.whitelistMint{value: whitelistPrice}(
            whitelistMinterProof,
            1
        );

        assertEq(nftContract.balanceOf(address(users.whitelistMinter)), 2);
    }

    function test_Revert_InvalidAmount_whitelistMint()
        public
        activeWhitelistRoot
        activeWhitelistMint
    {
        vm.prank(users.whitelistMinter);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.whitelistMint{value: 0}(whitelistMinterProof, 0);
    }

    function test_Revert_OverflowMaxSupply_whitelistMint()
        public
        mintedForOwner(nftContract.MAX_SUPPLY() - 1)
        activeWhitelistRoot
        activeWhitelistMint
    {
        uint256 whitelistMintQty = nftContract.WHITELIST_PER_WALLET();
        uint256 whitelistPrice = nftContract.WHITELIST_PRICE();
        vm.prank(users.whitelistMinter);
        vm.expectRevert(NFTName.OverflowMaxSupply.selector);
        nftContract.whitelistMint{value: whitelistPrice * whitelistMintQty}(
            whitelistMinterProof,
            whitelistMintQty
        );
    }

    function test_Revert_WhitelistMintClosed_whitelistMint()
        public
        activeWhitelistRoot
    {
        uint256 whitelistMintQty = nftContract.WHITELIST_PER_WALLET();
        uint256 whitelistPrice = nftContract.WHITELIST_PRICE();
        vm.prank(users.whitelistMinter);
        vm.expectRevert(NFTName.WhitelistMintClosed.selector);
        nftContract.whitelistMint{value: whitelistPrice * whitelistMintQty}(
            whitelistMinterProof,
            whitelistMintQty
        );
    }

    function test_Revert_HaveNotEligible_whitelistMint()
        public
        activeWhitelistRoot
        activeWhitelistMint
    {
        uint256 whitelistMintQty = nftContract.WHITELIST_PER_WALLET();
        uint256 whitelistPrice = nftContract.WHITELIST_PRICE();
        bytes32[] memory fakeProof = new bytes32[](1);
        fakeProof[0] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c3
        );
        vm.prank(users.whitelistMinter);
        vm.expectRevert(NFTName.HaveNotEligible.selector);
        nftContract.whitelistMint{value: whitelistPrice * whitelistMintQty}(
            fakeProof,
            whitelistMintQty
        );
    }

    function test_Revert_WhitelistMintLimitExceeded_whitelistMint()
        public
        activeWhitelistRoot
        activeWhitelistMint
    {
        uint256 whitelistMintQty = nftContract.WHITELIST_PER_WALLET();
        uint256 whitelistPrice = nftContract.WHITELIST_PRICE();
        vm.prank(users.whitelistMinter);
        vm.expectRevert(NFTName.WhitelistMintLimitExceeded.selector);
        nftContract.whitelistMint{
            value: whitelistPrice * (whitelistMintQty + 1)
        }(whitelistMinterProof, whitelistMintQty + 1);
    }

    function test_Revert_InsufficientBalance_whitelistMint()
        public
        activeWhitelistRoot
        activeWhitelistMint
    {
        uint256 whitelistMintQty = nftContract.WHITELIST_PER_WALLET();
        uint256 whitelistPrice = nftContract.WHITELIST_PRICE();
        vm.prank(users.whitelistMinter);
        vm.expectRevert(NFTName.InsufficientBalance.selector);
        nftContract.whitelistMint{value: whitelistPrice * whitelistMintQty - 1}(
            whitelistMinterProof,
            whitelistMintQty
        );
    }
}
