// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract freeMint is BaseSetup {
    bytes32[] public freeMinterProof = [
        bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        )
    ];
    // Defined in NFTContract.sol (If you change it, you need to change it here too)
    event MintedForFree(address indexed _to, uint256 _qty);

    function test_ShouldBeSuccess_freeMint() public activeFreelistRoot {
        uint256 freeMintQty = nftContract.FREE_PER_WALLET();
        vm.warp(nftContract.FREE_START());
        vm.prank(users.freeMinter);
        vm.expectEmit(address(nftContract));
        emit MintedForFree(address(users.freeMinter), freeMintQty);
        nftContract.freeMint(freeMinterProof, freeMintQty);

        assertEq(nftContract.totalSupply(), freeMintQty);
        assertEq(nftContract.balanceOf(address(users.freeMinter)), freeMintQty);
    }

    function test_ShouldBeSuccessIncreaseBalance_freeMint()
        public
        activeFreelistRoot
    {
        vm.warp(nftContract.FREE_START());
        vm.prank(users.freeMinter);
        nftContract.freeMint(freeMinterProof, 1);

        assertEq(nftContract.balanceOf(address(users.freeMinter)), 1);

        vm.prank(users.freeMinter);
        nftContract.freeMint(freeMinterProof, 1);

        assertEq(nftContract.balanceOf(address(users.freeMinter)), 2);
    }

    function test_Revert_FreeMintNotStarted_freeMint()
        public
        activeFreelistRoot
    {
        uint256 freeMintQty = nftContract.FREE_PER_WALLET();
        vm.prank(users.freeMinter);
        vm.expectRevert(NFTName.FreeMintNotStarted.selector);
        nftContract.freeMint(freeMinterProof, freeMintQty);
    }

    function test_Revert_FreeMintFinished_freeMint() public activeFreelistRoot {
        uint256 freeMintQty = nftContract.FREE_PER_WALLET();
        vm.warp(nftContract.FREE_STOP() + 1);
        vm.prank(users.freeMinter);
        vm.expectRevert(NFTName.FreeMintFinished.selector);
        nftContract.freeMint(freeMinterProof, freeMintQty);
    }

    function test_Revert_MintingStopped_freeMint() public activeFreelistRoot {
        uint256 freeMintQty = nftContract.FREE_PER_WALLET();
        vm.warp(nftContract.FREE_START());
        vm.prank(users.owner);
        nftContract.setMintStatus(true);
        vm.prank(users.freeMinter);
        vm.expectRevert(NFTName.MintingStopped.selector);
        nftContract.freeMint(freeMinterProof, freeMintQty);

        assertEq(nftContract.MINT_STATUS(), true);
    }

    function test_Revert_InvalidAmount_freeMint() public activeFreelistRoot {
        vm.warp(nftContract.FREE_START());
        vm.prank(users.freeMinter);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.freeMint(freeMinterProof, 0);
    }

    function test_Revert_OverflowMaxSupply_freeMint()
        public
        mintedForOwner(nftContract.MAX_SUPPLY() - 1)
        activeFreelistRoot
    {
        uint256 freeMintQty = nftContract.FREE_PER_WALLET();
        vm.warp(nftContract.FREE_START());
        vm.prank(users.freeMinter);
        vm.expectRevert(NFTName.OverflowMaxSupply.selector);
        nftContract.freeMint(freeMinterProof, freeMintQty);
    }

    function test_Revert_HaveNotEligible_freeMint() public activeFreelistRoot {
        uint256 freeMintQty = nftContract.FREE_PER_WALLET();
        bytes32[] memory fakeProof = new bytes32[](1);
        fakeProof[0] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c3
        );

        vm.warp(nftContract.FREE_START());
        vm.prank(users.freeMinter);
        vm.expectRevert(NFTName.HaveNotEligible.selector);
        nftContract.freeMint(fakeProof, freeMintQty);
    }

    function test_Revert_FreeMintLimitExceeded_freeMint()
        public
        activeFreelistRoot
    {
        uint256 freeMintQty = nftContract.FREE_PER_WALLET();
        vm.warp(nftContract.FREE_START());
        vm.prank(users.freeMinter);
        vm.expectRevert(NFTName.FreeMintLimitExceeded.selector);
        nftContract.freeMint(freeMinterProof, freeMintQty + 1);
    }
}
