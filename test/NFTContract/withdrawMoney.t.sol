// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract withdrawMoney is BaseSetup {
    function test_ShouldBeSuccess_withdrawMoney() public activePublicMint {
        uint256 publicMintQty = nftContract.PUBLIC_PER_WALLET();
        uint256 publicPrice = nftContract.PUBLIC_PRICE();

        vm.prank(users.publicMinter);
        nftContract.publicMint{value: publicPrice * publicMintQty}(
            publicMintQty
        );

        assertEq(address(nftContract).balance, publicPrice * publicMintQty);

        vm.prank(users.owner);
        nftContract.withdrawMoney();

        assertEq(address(nftContract).balance, 0);
    }

    function test_Revert_OnlyOwner_withdrawMoney() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.withdrawMoney();
    }
}
