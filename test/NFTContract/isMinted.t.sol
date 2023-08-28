// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract isMinted is BaseSetup {
    function test_ShouldBeSuccess_isMinted() public mintedForOwner(1) {
        assertTrue(nftContract.isMinted(0));
    }

    function test_Revert_InvalidTokenId_isMinted() public {
        assertFalse(nftContract.isMinted(0));
    }
}
