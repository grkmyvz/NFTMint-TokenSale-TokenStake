// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract tokenURI is BaseSetup {
    function test_ShouldBeSuccess_tokenURI() public mintedForOwner(2) {
        assertEq(nftContract.tokenURI(0), "https://localhost/0.json");
        assertEq(nftContract.tokenURI(1), "https://localhost/1.json");
    }

    function test_Revert_InvalidTokenId_tokenURI() public {
        vm.expectRevert("ERC721: invalid token ID");
        nftContract.tokenURI(1);
    }
}
