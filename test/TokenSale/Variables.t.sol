// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./BaseSetup.t.sol";

contract Variables is BaseSetup {
    function test_ShouldBeCheckVariables() public {
        assertEq(tokenSale.AIRDROP_AMOUNT(), 10);
        assertEq(tokenSale.AIRDROP_MAX_PER_WALLET(), 6);
        assertEq(tokenSale.AIRDROP_CLAIM_START_TIME(), 100);
        assertEq(tokenSale.AIRDROP_CLAIM_PERIOD(), 5);
        assertEq(tokenSale.SEEDSALE_AMOUNT(), 20);
        assertEq(tokenSale.SEEDSALE_MAX_PER_WALLET(), 11);
        assertEq(tokenSale.SEEDSALE_PRICE(), 0.1 ether);
        assertEq(tokenSale.SEEDSALE_CLAIM_START_TIME(), 200);
        assertEq(tokenSale.SEEDSALE_CLAIM_PERIOD(), 5);
        assertEq(tokenSale.PRESALE_AMOUNT(), 30);
        assertEq(tokenSale.PRESALE_MAX_PER_WALLET(), 16);
        assertEq(tokenSale.PRESALE_PRICE(), 0.2 ether);
        assertEq(tokenSale.PRESALE_CLAIM_START_TIME(), 300);
        assertEq(tokenSale.PRESALE_CLAIM_PERIOD(), 5);
        assertEq(tokenSale.PUBLICSALE_AMOUNT(), 40);
        assertEq(tokenSale.PUBLICSALE_MAX_PER_WALLET(), 21);
        assertEq(tokenSale.PUBLICSALE_PRICE(), 0.5 ether);
        assertEq(tokenSale.PUBLICSALE_CLAIM_START_TIME(), 400);
        assertEq(tokenSale.PUBLICSALE_CLAIM_PERIOD(), 5);
        assertEq(tokenSale.PERIOD_TIME(), 10);

        assertEq(tokenSale.airdropBuyed(), 0);
        assertEq(tokenSale.seedsaleBuyed(), 0);
        assertEq(tokenSale.presaleBuyed(), 0);
        assertEq(tokenSale.publicsaleBuyed(), 0);

        assertFalse(tokenSale.isTokenBalanceOk());
        assertFalse(tokenSale.airdropStatus());
        assertFalse(tokenSale.seedsaleStatus());
        assertFalse(tokenSale.presaleStatus());
        assertFalse(tokenSale.publicsaleStatus());

        assertTrue(tokenSale.airdropMerkleRoot() == bytes32(0));
        assertTrue(tokenSale.seedsaleMerkleRoot() == bytes32(0));
        assertTrue(tokenSale.presaleMerkleRoot() == bytes32(0));
    }
}
