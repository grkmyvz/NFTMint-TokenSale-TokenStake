// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract buyAirdrop is BaseSetup {
    bytes32[] public airdropMinter1Proof = [
        bytes32(
            0x8fcf3db81ddc9cee33449c63bc0db165bf61739ce0de36128f1e07c3f7f7b270
        ),
        bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        )
    ];

    bytes32[] public airdropMinter2Proof = [
        bytes32(
            0xf3842bdf78206d5c3eafbcfb18b437444b766491e2f82105bfefcd7f7365e933
        ),
        bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        )
    ];
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event AirdropBuyed(address indexed _to, uint256 _amount);

    function test_ShouldBeSuccess_buyAirdrop()
        public
        sendTokens
        activeAirdropRoot
        startedAirdrop
    {
        uint256 amount = tokenSale.AIRDROP_MAX_PER_WALLET();
        vm.prank(users.airdropBuyer1);
        vm.expectEmit(address(tokenSale));
        emit AirdropBuyed(address(users.airdropBuyer1), amount);
        tokenSale.buyAirdrop(airdropMinter1Proof);

        assertEq(tokenSale.airdropBuyed(), amount);
        assertEq(
            tokenSale.airdropBalances(address(users.airdropBuyer1)),
            amount
        );
    }

    function test_Revert_AirdropNotStarted_buyAirdrop()
        public
        sendTokens
        activeAirdropRoot
    {
        vm.prank(users.airdropBuyer1);
        vm.expectRevert(TokenSale.AirdropNotStarted.selector);
        tokenSale.buyAirdrop(airdropMinter1Proof);
    }

    function test_Revert_InvalidMerkleProof_buyAirdrop()
        public
        sendTokens
        activeAirdropRoot
        startedAirdrop
    {
        vm.prank(users.airdropBuyer1);
        vm.expectRevert(TokenSale.InvalidMerkleProof.selector);
        tokenSale.buyAirdrop(new bytes32[](0));
    }

    function test_Revert_AirdropAlreadyBuyed_buyAirdrop()
        public
        sendTokens
        activeAirdropRoot
        startedAirdrop
    {
        vm.startPrank(users.airdropBuyer1);
        tokenSale.buyAirdrop(airdropMinter1Proof);
        vm.expectRevert(TokenSale.AirdropAlreadyBuyed.selector);
        tokenSale.buyAirdrop(airdropMinter1Proof);
        vm.stopPrank();
    }

    function test_Revert_AirdropSoldOut_buyAirdrop()
        public
        sendTokens
        activeAirdropRoot
        startedAirdrop
    {
        vm.prank(users.airdropBuyer1);
        tokenSale.buyAirdrop(airdropMinter1Proof);
        vm.prank(users.airdropBuyer2);
        vm.expectRevert(TokenSale.AirdropSoldOut.selector);
        tokenSale.buyAirdrop(airdropMinter2Proof);
    }
}
