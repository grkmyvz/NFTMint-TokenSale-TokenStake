// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract buyPresale is BaseSetup {
    bytes32[] public presaleMinter1Proof = [
        bytes32(
            0x3e166e3b353fca9c2d646d7ad8f49e4208eaffbc97b118375228935a388df3fa
        ),
        bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        )
    ];

    bytes32[] public presaleMinter2Proof = [
        bytes32(
            0x86fe92e0c489bc7162d502ace7e5b441c6aa24aae52e29c376feac18224d07a1
        ),
        bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        )
    ];
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event PresaleBuyed(address indexed _to, uint256 _amount);

    function test_ShouldBeSuccess_buyPresale()
        public
        sendTokens
        activePresaleRoot
        startedPresale
    {
        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 price = tokenSale.PRESALE_PRICE();
        uint256 beforePresaleBuyer1Balance = address(users.presaleBuyer1)
            .balance;
        uint256 beforeTokenSaleBalance = address(tokenSale).balance;
        vm.prank(users.presaleBuyer1);
        vm.expectEmit(address(tokenSale));
        emit PresaleBuyed(address(users.presaleBuyer1), amount);
        tokenSale.buyPresale{value: amount * price}(
            presaleMinter1Proof,
            amount
        );

        assertEq(tokenSale.presaleBuyed(), amount);
        assertEq(
            tokenSale.presaleBalances(address(users.presaleBuyer1)),
            amount
        );
        assertEq(
            address(users.presaleBuyer1).balance,
            beforePresaleBuyer1Balance - (amount * price)
        );
        assertEq(
            address(tokenSale).balance,
            beforeTokenSaleBalance + (amount * price)
        );
    }

    function test_Revert_PresaleNotStarted_buyPresale()
        public
        sendTokens
        activePresaleRoot
    {
        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.PresaleNotStarted.selector);
        tokenSale.buyPresale{value: 1}(presaleMinter1Proof, 1);
    }

    function test_Revert_InvalidAmount1_buyPresale()
        public
        sendTokens
        activePresaleRoot
        startedPresale
    {
        uint256 amount = 0;
        uint256 price = tokenSale.PRESALE_PRICE();
        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.InvalidAmount.selector);
        tokenSale.buyPresale{value: amount * price}(
            presaleMinter1Proof,
            amount
        );
    }

    function test_RevertInvalidAmount2_buyPresale()
        public
        sendTokens
        activePresaleRoot
        startedPresale
    {
        uint256 amount = tokenSale.PRESALE_CLAIM_PERIOD() - 1;
        uint256 price = tokenSale.PRESALE_PRICE();
        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.InvalidAmount.selector);
        tokenSale.buyPresale{value: amount * price}(
            presaleMinter1Proof,
            amount
        );
    }

    function test_Revert_InvalidMerkleProof_buyPresale()
        public
        sendTokens
        activePresaleRoot
        startedPresale
    {
        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 price = tokenSale.PRESALE_PRICE();
        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.InvalidMerkleProof.selector);
        tokenSale.buyPresale{value: amount * price}(new bytes32[](0), amount);
    }

    function test_Revert_PresaleMaxPerWalletExceeded_buyPresale()
        public
        sendTokens
        activePresaleRoot
        startedPresale
    {
        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET() + 1;
        uint256 price = tokenSale.PRESALE_PRICE();
        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.PresaleMaxPerWalletExceeded.selector);
        tokenSale.buyPresale{value: amount * price}(
            presaleMinter1Proof,
            amount
        );
    }

    function test_Revert_PresaleSoldOut_buyPresale()
        public
        sendTokens
        activePresaleRoot
        startedPresale
    {
        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 price = tokenSale.PRESALE_PRICE();
        vm.prank(users.presaleBuyer1);
        tokenSale.buyPresale{value: amount * price}(
            presaleMinter1Proof,
            amount
        );
        vm.prank(users.presaleBuyer2);
        vm.expectRevert(TokenSale.PresaleSoldOut.selector);
        tokenSale.buyPresale{value: amount * price}(
            presaleMinter2Proof,
            amount
        );
    }

    function test_Revert_InvalidBalance_buyPresale()
        public
        sendTokens
        activePresaleRoot
        startedPresale
    {
        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 price = tokenSale.PRESALE_PRICE();
        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.InvalidBalance.selector);
        tokenSale.buyPresale{value: (amount * price) - 1}(
            presaleMinter1Proof,
            amount
        );
    }
}
