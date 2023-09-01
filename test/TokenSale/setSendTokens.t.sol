// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract setSendTokens is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event SendTokens(uint256 _amount);

    function sumAmount() public view returns (uint256) {
        return
            (tokenSale.AIRDROP_AMOUNT() +
                tokenSale.SEEDSALE_AMOUNT() +
                tokenSale.PRESALE_AMOUNT() +
                tokenSale.PUBLICSALE_AMOUNT()) * 10 ** 18;
    }

    function test_ShouldBeSuccess_setSendTokens() public {
        uint256 amount = sumAmount();
        vm.startPrank(users.owner);
        testToken.approve(address(tokenSale), amount);
        vm.expectEmit(address(tokenSale));
        emit SendTokens(amount);
        tokenSale.setSendTokens(amount);
        vm.stopPrank();
    }

    function test_Revert_OnlyOwner_setSendTokens() public {
        uint256 amount = sumAmount();
        vm.startPrank(users.owner);
        testToken.transfer(address(users.guest), amount);
        vm.stopPrank();
        vm.startPrank(users.guest);
        testToken.approve(address(tokenSale), amount);
        vm.expectRevert("Ownable: caller is not the owner");
        tokenSale.setSendTokens(amount);
        vm.stopPrank();
    }

    function test_Revert_TokenBalanceAlreadyOk_setSendTokens()
        public
        sendTokens
    {
        uint256 amount = sumAmount();
        vm.startPrank(users.owner);
        testToken.approve(address(tokenSale), amount);
        vm.expectRevert(TokenSale.TokenBalanceAlreadyOk.selector);
        tokenSale.setSendTokens(amount);
        vm.stopPrank();
    }

    function test_Revert_InvalidAmount_setSendTokens() public {
        uint256 amount = sumAmount();
        vm.startPrank(users.owner);
        testToken.approve(address(tokenSale), amount);
        vm.expectRevert(TokenSale.InvalidAmount.selector);
        tokenSale.setSendTokens(amount - 1);
        vm.stopPrank();
    }
}
