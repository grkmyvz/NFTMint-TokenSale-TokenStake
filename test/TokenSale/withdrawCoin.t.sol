// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract withdrawCoin is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event OwnerWithdrawCoin(uint256 _amount, bytes _data);

    function test_ShouldBeSuccess_withdrawCoin() public {
        uint256 ownerBalance = address(users.owner).balance;
        uint256 amount = 1 ether;

        vm.prank(users.guest);
        (bool success, bytes memory data) = address(tokenSale).call{
            value: amount
        }("");
        if (!success) {
            revert(string(data));
        }

        assertEq(address(tokenSale).balance, amount);

        vm.startPrank(users.owner);
        vm.expectEmit(address(tokenSale));
        emit OwnerWithdrawCoin(amount, "");
        tokenSale.withdrawCoin();
        vm.stopPrank();

        assertEq(address(tokenSale).balance, 0);
        assertEq(address(users.owner).balance, ownerBalance + amount);
    }
}
