// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../lib/forge-std/src/Test.sol";
import "./utils/Token.sol";
import "../../src/TokenSale.sol";
import {Users} from "./utils/Users.sol";

contract BaseSetup is Test {
    TestToken public testToken;
    TokenSale public tokenSale;

    Users internal users;

    uint256 public constant WALLET_BALANCE = 100 ether;

    modifier sendTokens() {
        uint256 amount = (tokenSale.AIRDROP_AMOUNT() +
            tokenSale.SEEDSALE_AMOUNT() +
            tokenSale.PRESALE_AMOUNT() +
            tokenSale.PUBLICSALE_AMOUNT()) * 10 ** 18;
        vm.startPrank(users.owner);
        testToken.approve(address(tokenSale), amount);
        tokenSale.setSendTokens(amount);
        vm.stopPrank();
        _;
    }

    modifier activeAirdropRoot() {
        vm.prank(users.owner);
        tokenSale.setAirdropMerkleRoot(
            bytes32(
                0x41662cb859d4f1094219631530ee4b5a1cd226ea8a2ecbac09236dcc5183b453
            )
        );
        _;
    }

    modifier activeSeedsaleRoot() {
        vm.prank(users.owner);
        tokenSale.setSeedsaleMerkleRoot(
            bytes32(
                0x449506d84ba1c28422e518ba1653f80ec291e2236d5b7e216ad9b16d7ff5d2ab
            )
        );
        _;
    }

    modifier activePresaleRoot() {
        vm.prank(users.owner);
        tokenSale.setPresaleMerkleRoot(
            bytes32(
                0x707c7ea54a14e4c0fceaf9b739af24613eaa2709f6b1dbc2331e92362a733d58
            )
        );
        _;
    }

    modifier startedAirdrop() {
        vm.prank(users.owner);
        tokenSale.setAirdropStatus(true);
        _;
    }

    modifier startedSeedsale() {
        vm.prank(users.owner);
        tokenSale.setSeedsaleStatus(true);
        _;
    }

    modifier startedPresale() {
        vm.prank(users.owner);
        tokenSale.setPresaleStatus(true);
        _;
    }

    modifier startedPublicsale() {
        vm.prank(users.owner);
        tokenSale.setPublicsaleStatus(true);
        _;
    }

    constructor() {}

    function setUp() public {
        users = Users({
            owner: createUser("Owner"),
            airdropBuyer1: createUser("AirdropBuyer1"),
            airdropBuyer2: createUser("AirdropBuyer2"),
            seedsaleBuyer1: createUser("SeedsaleBuyer1"),
            seedsaleBuyer2: createUser("SeedsaleBuyer2"),
            presaleBuyer1: createUser("PresaleBuyer1"),
            presaleBuyer2: createUser("PresaleBuyer2"),
            publicsaleBuyer1: createUser("PublicsaleBuyer1"),
            publicsaleBuyer2: createUser("PublicsaleBuyer2"),
            guest: createUser("Guest")
        });

        vm.startPrank(users.owner);
        testToken = new TestToken();
        tokenSale = new TokenSale(address(testToken));
        vm.stopPrank();
    }

    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({account: user, newBalance: WALLET_BALANCE});
        return user;
    }

    function test_ShouldBeSetup() public {
        assertEq(address(users.owner).balance, WALLET_BALANCE);
        assertEq(address(users.airdropBuyer1).balance, WALLET_BALANCE);
        assertEq(address(users.airdropBuyer2).balance, WALLET_BALANCE);
        assertEq(address(users.seedsaleBuyer1).balance, WALLET_BALANCE);
        assertEq(address(users.seedsaleBuyer2).balance, WALLET_BALANCE);
        assertEq(address(users.presaleBuyer1).balance, WALLET_BALANCE);
        assertEq(address(users.presaleBuyer2).balance, WALLET_BALANCE);
        assertEq(address(users.publicsaleBuyer1).balance, WALLET_BALANCE);
        assertEq(address(users.publicsaleBuyer2).balance, WALLET_BALANCE);
        assertEq(address(users.guest).balance, WALLET_BALANCE);
        assertTrue(address(testToken) != address(0));
        assertTrue(address(tokenSale) != address(0));

        emit log_named_address("Owner Address", address(users.owner));
        emit log_named_address(
            "AirdropBuyer1 Address",
            address(users.airdropBuyer1)
        );
        emit log_named_address(
            "AirdropBuyer2 Address",
            address(users.airdropBuyer2)
        );
        emit log_named_address(
            "SeedsaleBuyer1 Address",
            address(users.seedsaleBuyer1)
        );
        emit log_named_address(
            "SeedsaleBuyer2 Address",
            address(users.seedsaleBuyer2)
        );
        emit log_named_address(
            "PresaleBuyer1 Address",
            address(users.presaleBuyer1)
        );
        emit log_named_address(
            "PresaleBuyer2 Address",
            address(users.presaleBuyer2)
        );
        emit log_named_address(
            "PublicsaleBuyer1 Address",
            address(users.publicsaleBuyer1)
        );
        emit log_named_address(
            "PublicsaleBuyer2 Address",
            address(users.publicsaleBuyer2)
        );
        emit log_named_address("Guest Address", address(users.guest));
        emit log_named_address("TestToken Address", address(testToken));
        emit log_named_address("TokenSale Address", address(tokenSale));
    }
}
