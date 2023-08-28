// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/NFTContract.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract multipleTransfer is BaseSetup {
    function test_ShouldBeSuccess_multipleTransfer() public mintedForOwner(5) {
        uint256[] memory sentTokens = new uint256[](3);
        sentTokens[0] = 0;
        sentTokens[1] = 3;
        sentTokens[2] = 4;
        uint256[] memory remainingTokens = new uint256[](2);
        remainingTokens[0] = 2;
        remainingTokens[1] = 1;
        vm.prank(users.owner);
        nftContract.multipleTransfer(address(users.guest), sentTokens);

        assertEq(nftContract.balanceOf(address(users.owner)), 2);
        assertEq(nftContract.balanceOf(address(users.guest)), 3);
        assertEq(
            nftContract.getTokenListByOwner(address(users.guest)),
            sentTokens
        );
        assertEq(
            nftContract.getTokenListByOwner(address(users.owner)),
            remainingTokens
        );
    }

    function test_Revert_InvalidAddress1_multipleTransfer()
        public
        mintedForOwner(5)
    {
        uint256[] memory sentTokens = new uint256[](3);
        sentTokens[0] = 0;
        sentTokens[1] = 3;
        sentTokens[2] = 4;
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidAddress.selector);
        nftContract.multipleTransfer(address(0), sentTokens);
    }

    function test_Revert_InvalidAddress2_multipleTransfer()
        public
        mintedForOwner(5)
    {
        uint256[] memory sentTokens = new uint256[](3);
        sentTokens[0] = 0;
        sentTokens[1] = 3;
        sentTokens[2] = 4;
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidAddress.selector);
        nftContract.multipleTransfer(address(users.owner), sentTokens);
    }

    function test_Revert_InvalidAmount1_multipleTransfer()
        public
        mintedForOwner(5)
    {
        uint256[] memory sentTokens = new uint256[](0);
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.multipleTransfer(address(users.guest), sentTokens);
    }

    function test_Revert_InvalidAmount2_multipleTransfer()
        public
        mintedForOwner(5)
    {
        uint256[] memory sentTokens = new uint256[](1);
        sentTokens[0] = 2;
        vm.prank(users.owner);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.multipleTransfer(address(users.guest), sentTokens);
    }

    function test_Revert_YouNotTokenHolder_multipleTransfer()
        public
        mintedForOwner(5)
    {
        uint256[] memory sentTokens = new uint256[](3);
        sentTokens[0] = 0;
        sentTokens[1] = 3;
        sentTokens[2] = 4;
        vm.prank(users.guest);
        vm.expectRevert(NFTName.YouNotTokenHolder.selector);
        nftContract.multipleTransfer(address(users.owner), sentTokens);
    }
}
