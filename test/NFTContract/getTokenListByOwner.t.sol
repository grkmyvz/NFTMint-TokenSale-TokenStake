// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract getTokenListByOwner is BaseSetup {
    function test_ShouldBeSuccess_getTokenListByOwner()
        public
        mintedForOwner(2)
    {
        assertEq(nftContract.getTokenListByOwner(users.owner).length, 2);
        assertEq(nftContract.getTokenListByOwner(users.owner)[0], 0);
        assertEq(nftContract.getTokenListByOwner(users.owner)[1], 1);

        assertEq(nftContract.getTokenListByOwner(users.guest).length, 0);
    }
}
