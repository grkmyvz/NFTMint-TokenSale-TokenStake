// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract buyPublicsale is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event PublicsaleBuyed(address indexed _to, uint256 _amount);

    function test_ShouldBeSuccess_buyPublicsale()
        public
        sendTokens
        startedPublicsale
    {
        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET();
        uint256 price = tokenSale.PUBLICSALE_PRICE();
        uint256 beforePublicsaleBuyer1Balance = address(users.publicsaleBuyer1)
            .balance;
        uint256 beforeTokenSaleBalance = address(tokenSale).balance;
        vm.prank(users.publicsaleBuyer1);
        vm.expectEmit(address(tokenSale));
        emit PublicsaleBuyed(address(users.publicsaleBuyer1), amount);
        tokenSale.buyPublicsale{value: amount * price}(amount);

        assertEq(tokenSale.publicsaleBuyed(), amount);
        assertEq(
            tokenSale.publicsaleBalances(address(users.publicsaleBuyer1)),
            amount
        );
        assertEq(
            address(users.publicsaleBuyer1).balance,
            beforePublicsaleBuyer1Balance - (amount * price)
        );
        assertEq(
            address(tokenSale).balance,
            beforeTokenSaleBalance + (amount * price)
        );
    }

    function test_Revert_PublicsaleNotStarted_buyPublicsale()
        public
        sendTokens
    {
        vm.prank(users.publicsaleBuyer1);
        vm.expectRevert(TokenSale.PublicsaleNotStarted.selector);
        tokenSale.buyPublicsale(1);
    }

    function test_Revert_InvalidAmount1_buyPublicsale()
        public
        sendTokens
        startedPublicsale
    {
        uint256 amount = 0;
        uint256 price = tokenSale.PUBLICSALE_PRICE();
        vm.prank(users.publicsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidAmount.selector);
        tokenSale.buyPublicsale{value: amount * price}(amount);
    }

    function test_Revert_InvalidAmount2_buyPublicsale()
        public
        sendTokens
        startedPublicsale
    {
        uint256 amount = tokenSale.PUBLICSALE_CLAIM_PERIOD() - 1;
        uint256 price = tokenSale.PUBLICSALE_PRICE();
        vm.prank(users.publicsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidAmount.selector);
        tokenSale.buyPublicsale{value: amount * price}(amount);
    }

    function test_Revert_PublicsaleMaxPerWalletExceeded_buyPublicsale()
        public
        sendTokens
        startedPublicsale
    {
        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET() + 1;
        uint256 price = tokenSale.PUBLICSALE_PRICE();
        vm.prank(users.publicsaleBuyer1);
        vm.expectRevert(TokenSale.PublicsaleMaxPerWalletExceeded.selector);
        tokenSale.buyPublicsale{value: amount * price}(amount);
    }

    function test_Revert_PublicsaleSoldOut_buyPublicSale()
        public
        sendTokens
        startedPublicsale
    {
        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET();
        uint256 price = tokenSale.PUBLICSALE_PRICE();
        vm.prank(users.airdropBuyer1);
        tokenSale.buyPublicsale{value: amount * price}(amount);
        vm.prank(users.airdropBuyer2);
        tokenSale.buyPublicsale{value: amount * price}(amount);
        vm.prank(users.seedsaleBuyer1);
        tokenSale.buyPublicsale{value: amount * price}(amount);
        vm.prank(users.publicsaleBuyer1);
        tokenSale.buyPublicsale{value: amount * price}(amount);
        vm.prank(users.publicsaleBuyer2);
        vm.expectRevert(TokenSale.PublicsaleSoldOut.selector);
        tokenSale.buyPublicsale{value: amount * price}(amount);
    }

    function test_Revert_InvalidBalance_buyPublicsale()
        public
        sendTokens
        startedPublicsale
    {
        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET();
        uint256 price = tokenSale.PUBLICSALE_PRICE();
        vm.prank(users.publicsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidBalance.selector);
        tokenSale.buyPublicsale{value: (amount * price) - 1}(amount);
    }
}
