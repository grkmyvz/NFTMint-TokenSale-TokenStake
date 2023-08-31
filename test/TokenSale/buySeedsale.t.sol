// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract buySeedsale is BaseSetup {
    bytes32[] public seedsaleMinter1Proof = [
        bytes32(
            0xf9ff3bcd5ae7b826e9d51586d3a61d5edc6b8a8a5916c90b44b4172d4082fda9
        ),
        bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        )
    ];

    bytes32[] public seedsaleMinter2Proof = [
        bytes32(
            0x444c6da82af0f0b56a9357fd0933055f47c9c2c709a4e0a35235f1e141331d86
        ),
        bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        )
    ];
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event SeedsaleBuyed(address indexed _to, uint256 _amount);

    function test_ShouldBeSuccess_buySeedsale()
        public
        sendTokens
        activeSeedsaleRoot
        startedSeedsale
    {
        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        uint256 price = tokenSale.SEEDSALE_PRICE();
        uint256 beforeSeedsaleBuyer1Balance = address(users.seedsaleBuyer1)
            .balance;
        uint256 beforeTokenSaleBalance = address(tokenSale).balance;
        vm.prank(users.seedsaleBuyer1);
        vm.expectEmit(address(tokenSale));
        emit SeedsaleBuyed(address(users.seedsaleBuyer1), amount);
        tokenSale.buySeedsale{value: amount * price}(
            seedsaleMinter1Proof,
            amount
        );

        assertEq(tokenSale.seedsaleBuyed(), amount);
        assertEq(
            tokenSale.seedsaleBalances(address(users.seedsaleBuyer1)),
            amount
        );
        assertEq(
            address(users.seedsaleBuyer1).balance,
            beforeSeedsaleBuyer1Balance - (amount * price)
        );
        assertEq(
            address(tokenSale).balance,
            beforeTokenSaleBalance + (amount * price)
        );
    }

    function test_Revert_SeedsaleNotStarted_buySeedsale()
        public
        sendTokens
        activeSeedsaleRoot
    {
        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.SeedsaleNotStarted.selector);
        tokenSale.buySeedsale{value: 1}(seedsaleMinter1Proof, 1);
    }

    function test_Revert_InvalidAmount1_buySeedsale()
        public
        sendTokens
        activeSeedsaleRoot
        startedSeedsale
    {
        uint256 amount = 0;
        uint256 price = tokenSale.SEEDSALE_PRICE();
        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidAmount.selector);
        tokenSale.buySeedsale{value: amount * price}(
            seedsaleMinter1Proof,
            amount
        );
    }

    function test_Revert_InvalidAmount2_buySeedsale()
        public
        sendTokens
        activeSeedsaleRoot
        startedSeedsale
    {
        uint256 amount = tokenSale.SEEDSALE_CLAIM_PERIOD() - 1;
        uint256 price = tokenSale.SEEDSALE_PRICE();
        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidAmount.selector);
        tokenSale.buySeedsale{value: amount * price}(
            seedsaleMinter1Proof,
            amount
        );
    }

    function test_Revert_InvalidMerkleProof_buySeedsale()
        public
        sendTokens
        activeSeedsaleRoot
        startedSeedsale
    {
        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        uint256 price = tokenSale.SEEDSALE_PRICE();
        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidMerkleProof.selector);
        tokenSale.buySeedsale{value: amount * price}(new bytes32[](0), amount);
    }

    function test_Revert_SeedsaleMaxPerWalletExceeded_buySeedsale()
        public
        sendTokens
        activeSeedsaleRoot
        startedSeedsale
    {
        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET() + 1;
        uint256 price = tokenSale.SEEDSALE_PRICE();
        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.SeedsaleMaxPerWalletExceeded.selector);
        tokenSale.buySeedsale{value: amount * price}(
            seedsaleMinter1Proof,
            amount
        );
    }

    function test_Revert_SeedsaleSoldOut_buySeedsale()
        public
        sendTokens
        activeSeedsaleRoot
        startedSeedsale
    {
        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        uint256 price = tokenSale.SEEDSALE_PRICE();
        vm.prank(users.seedsaleBuyer1);
        tokenSale.buySeedsale{value: amount * price}(
            seedsaleMinter1Proof,
            amount
        );
        vm.prank(users.seedsaleBuyer2);
        vm.expectRevert(TokenSale.SeedsaleSoldOut.selector);
        tokenSale.buySeedsale{value: amount * price}(
            seedsaleMinter2Proof,
            amount
        );
    }

    function test_Revert_InvalidBalance_buySeedsale()
        public
        sendTokens
        activeSeedsaleRoot
        startedSeedsale
    {
        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        uint256 price = tokenSale.SEEDSALE_PRICE();
        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidBalance.selector);
        tokenSale.buySeedsale{value: (amount * price) - 1}(
            seedsaleMinter1Proof,
            amount
        );
    }
}
