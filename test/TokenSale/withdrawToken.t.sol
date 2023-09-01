// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract withdrawToken is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event OwnerWithdrawToken(uint256 _amount);

    function test_ShouldBeSuccess_withdrawToken() public sendTokens {
        uint256 contractBalance = testToken.balanceOf(address(tokenSale));
        uint256 ownerBalance = testToken.balanceOf(address(users.owner));

        vm.startPrank(users.owner);
        vm.expectEmit(address(tokenSale));
        emit OwnerWithdrawToken(contractBalance);
        tokenSale.withdrawToken();
        vm.stopPrank();

        assertEq(testToken.balanceOf(address(tokenSale)), 0);
        assertEq(
            testToken.balanceOf(address(users.owner)),
            ownerBalance + contractBalance
        );
    }
}
