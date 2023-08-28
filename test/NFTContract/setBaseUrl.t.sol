// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract setBaseUrl is BaseSetup {
    function test_ShouldBeSuccess_setBaseUrl() public {
        vm.prank(users.owner);
        nftContract.setBaseUrl("https://localhost2/");
        assertEq(nftContract.BASE_URL(), "https://localhost2/");
    }

    function test_Revert_OnlyOwner_setBaseUrl() public {
        vm.prank(users.guest);
        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.setBaseUrl("https://localhost2/");
    }
}
