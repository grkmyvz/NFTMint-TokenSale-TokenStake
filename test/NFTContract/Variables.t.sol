// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract Variables is BaseSetup {
    function test_ShouldBeCheckVariables() public {
        assertEq(nftContract.MAX_SUPPLY(), 1000);
        assertEq(nftContract.FREE_START(), 2);
        assertEq(nftContract.FREE_STOP(), 4);
        assertEq(nftContract.FREE_PER_WALLET(), 2);
        assertEq(nftContract.WHITELIST_START(), 5);
        assertEq(nftContract.WHITELIST_STOP(), 8);
        assertEq(nftContract.WHITELIST_PER_WALLET(), 10);
        assertEq(nftContract.WHITELIST_PRICE(), 0.1 ether);
        assertEq(nftContract.PUBLIC_START(), 9);
        assertEq(nftContract.PUBLIC_PER_WALLET(), 5);
        assertEq(nftContract.PUBLIC_PRICE(), 0.2 ether);
        assertEq(nftContract.BASE_URL(), "https://localhost/");
    }
}
