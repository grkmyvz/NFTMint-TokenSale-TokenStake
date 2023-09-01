// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/TokenSale.sol";

contract TokenSaleTest is Test {
    MyToken public token;
    TokenSale public tokenSale;

    address public contractOwner;
    address public user1;
    address public user2;
    address public user3;
    address public user4;
    address public user5;
    address public user6;
    address public user7;
    address public user8;
    address public user9;
    address public member1;

    function setUp() public {
        contractOwner = vm.addr(1);
        user1 = vm.addr(2);
        user2 = vm.addr(3);
        user3 = vm.addr(4);
        user4 = vm.addr(5);
        user5 = vm.addr(6);
        user6 = vm.addr(7);
        user7 = vm.addr(8);
        user8 = vm.addr(9);
        user9 = vm.addr(10);
        member1 = vm.addr(11);
        vm.deal(contractOwner, 100 ether);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
        vm.deal(user4, 100 ether);
        vm.deal(user5, 100 ether);
        vm.deal(user6, 100 ether);
        vm.deal(user7, 100 ether);
        vm.deal(user8, 100 ether);
        vm.deal(user9, 100 ether);
        vm.deal(member1, 100 ether);
        vm.startPrank(contractOwner);
        token = new MyToken();
        tokenSale = new TokenSale(address(token));
        token.approve(address(tokenSale), 110 * 10 ** 18);
        tokenSale.setSendTokens(110 * 10 ** 18);
        vm.stopPrank();
        emit log_named_address("Token Address", address(token));
        emit log_named_address("Token Sale Address", address(tokenSale));
        emit log_named_address("Contract Owner", contractOwner);
        emit log_named_address("User 1", user1);
        emit log_named_address("User 2", user2);
        emit log_named_address("User 3", user3);
        emit log_named_address("User 4", user4);
        emit log_named_address("User 5", user5);
        emit log_named_address("User 6", user6);
        emit log_named_address("User 7", user7);
        emit log_named_address("User 8", user8);
        emit log_named_address("User 9", user9);
        emit log_named_address("Member 1", member1);
    }

    function testContract() public {
        assertTrue(address(this) != address(0));
        assertTrue(address(token) != address(0));
        assertTrue(address(tokenSale) != address(0));
        assertTrue(address(contractOwner) != address(0));
        assertTrue(address(user1) != address(0));
        assertTrue(address(user2) != address(0));
        assertTrue(address(user3) != address(0));
        assertTrue(address(user4) != address(0));
        assertTrue(address(user5) != address(0));
        assertTrue(address(user6) != address(0));
        assertTrue(address(user7) != address(0));
        assertTrue(address(user8) != address(0));
        assertTrue(address(user9) != address(0));
        assertTrue(address(member1) != address(0));

        assertTrue(address(user1).balance == 100000000000000000000);
        assertTrue(address(user2).balance == 100000000000000000000);
        assertTrue(address(user3).balance == 100000000000000000000);
        assertTrue(address(user4).balance == 100000000000000000000);
        assertTrue(address(user5).balance == 100000000000000000000);
        assertTrue(address(user6).balance == 100000000000000000000);
        assertTrue(address(user7).balance == 100000000000000000000);
        assertTrue(address(user8).balance == 100000000000000000000);
        assertTrue(address(user9).balance == 100000000000000000000);
        assertTrue(address(member1).balance == 100000000000000000000);
        assertTrue(
            token.balanceOf(address(contractOwner)) ==
                (1000000 * 10 ** 18) - (110 * 10 ** 18)
        );
        assertTrue(token.balanceOf(address(tokenSale)) == 110 * 10 ** 18);
        assertTrue(tokenSale.isTokenBalanceOk() == true);
        assertTrue(tokenSale.isAirdropStarted() == false);
        assertTrue(tokenSale.isPresaleStarted() == false);
        assertTrue(tokenSale.isSeedsaleStarted() == false);
        assertTrue(tokenSale.isPublicsaleStarted() == false);

        emit log("-----> Addresses, Balances and Variables Test (OKAY)");
        tMerkleRoots();
    }

    function tMerkleRoots() public {
        vm.startPrank(contractOwner);
        tokenSale.setAirdropMerkleRoot(
            bytes32(
                0x1a22147bba2925efd48ca48b860220617600b681013c3f91680b51b082bed39f
            )
        );
        tokenSale.setSeedsaleMerkleRoot(
            bytes32(
                0x073d9c846828def16f872ba1c3c9da0d9eda7d47d652658b3203daf28cb1f398
            )
        );
        tokenSale.setPresaleMerkleRoot(
            bytes32(
                0x724188b029894cbd0e18f48c6bdbae3bc4a10d47cdb48eb6eeb9899975a3fcb3
            )
        );
        vm.stopPrank();

        assertTrue(
            tokenSale.airdropMerkleRoot() ==
                bytes32(
                    0x1a22147bba2925efd48ca48b860220617600b681013c3f91680b51b082bed39f
                )
        );
        assertTrue(
            tokenSale.seedsaleMerkleRoot() ==
                bytes32(
                    0x073d9c846828def16f872ba1c3c9da0d9eda7d47d652658b3203daf28cb1f398
                )
        );
        assertTrue(
            tokenSale.presaleMerkleRoot() ==
                bytes32(
                    0x724188b029894cbd0e18f48c6bdbae3bc4a10d47cdb48eb6eeb9899975a3fcb3
                )
        );

        emit log("-----> Merkle Roots Test (OKAY)");
        tBuyAirdrop();
    }

    // TODO: Max supply test
    function tBuyAirdrop() public {
        vm.prank(contractOwner);
        tokenSale.setStartAirdrop(true);

        assertTrue(tokenSale.isAirdropStarted() == true);

        bytes32[] memory user1Proof = new bytes32[](2);
        user1Proof[0] = bytes32(
            0x1bec7c333d3d0c3eef8c6199a402856509c3f869d25408cc1cc2208d0371db0e
        );
        user1Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );
        bytes32[] memory user2Proof = new bytes32[](2);
        user2Proof[0] = bytes32(
            0x94a6fc29a44456b36232638a7042431c9c91b910df1c52187179085fac1560e9
        );
        user2Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );

        vm.prank(user1);
        tokenSale.buyAirdrop(user1Proof);
        assertTrue(
            tokenSale.airdropBalances(user1) ==
                tokenSale.AIRDROP_MAX_PER_WALLET()
        );
        assertTrue(
            tokenSale.airdropBuyed() == tokenSale.AIRDROP_MAX_PER_WALLET()
        );

        vm.prank(user2);
        tokenSale.buyAirdrop(user2Proof);
        assertTrue(
            tokenSale.airdropBalances(user2) ==
                tokenSale.AIRDROP_MAX_PER_WALLET()
        );
        assertTrue(
            tokenSale.airdropBuyed() == tokenSale.AIRDROP_MAX_PER_WALLET() * 2
        );

        assertTrue(tokenSale.AIRDROP_AMOUNT() - tokenSale.airdropBuyed() == 0);

        vm.prank(contractOwner);
        tokenSale.setStartAirdrop(false);
        assertTrue(tokenSale.isAirdropStarted() == false);

        emit log("-----> Airdrop Test (OKAY)");
        tBuySeedsale();
    }

    function tBuySeedsale() public {
        vm.prank(contractOwner);
        tokenSale.setStartSeedsale(true);

        assertTrue(tokenSale.isSeedsaleStarted() == true);

        bytes32[] memory user3Proof = new bytes32[](2);
        user3Proof[0] = bytes32(
            0x0ec177b07a450912768b0990e3f3942da56d7b24528a8ff010fef62bdc36ed2b
        );
        user3Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );
        bytes32[] memory user4Proof = new bytes32[](2);
        user4Proof[0] = bytes32(
            0x1143df8268b94bd6292fdd7c9b8af39a79f764cfc03ae006844446bc91203927
        );
        user4Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );

        uint256 user3Amount = 10;
        uint256 user3Value = tokenSale.SEEDSALE_PRICE() * user3Amount;
        uint256 user4Amount = 10;
        uint256 user4Value = tokenSale.SEEDSALE_PRICE() * user4Amount;

        vm.startPrank(user3);
        tokenSale.buySeedsale{value: user3Value}(user3Proof, user3Amount);
        vm.stopPrank();

        assertTrue(tokenSale.seedsaleBalances(user3) == user3Amount);
        assertTrue(tokenSale.seedsaleBuyed() == user3Amount);
        assertTrue(
            address(user3).balance == 100000000000000000000 - user3Value
        );

        vm.startPrank(user4);
        tokenSale.buySeedsale{value: user4Value}(user4Proof, user4Amount);
        vm.stopPrank();

        assertTrue(tokenSale.seedsaleBalances(user4) == user4Amount);
        assertTrue(tokenSale.seedsaleBuyed() == user3Amount + user4Amount);
        assertTrue(
            address(user4).balance == 100000000000000000000 - user4Value
        );

        assertTrue(
            tokenSale.SEEDSALE_AMOUNT() - tokenSale.seedsaleBuyed() == 0
        );

        vm.prank(contractOwner);
        tokenSale.setStartSeedsale(false);
        assertTrue(tokenSale.isSeedsaleStarted() == false);

        emit log("-----> Seedsale Test (OKAY)");
        tBuyPresale();
    }

    function tBuyPresale() public {
        vm.prank(contractOwner);
        tokenSale.setStartPresale(true);

        assertTrue(tokenSale.isPresaleStarted() == true);

        bytes32[] memory user5Proof = new bytes32[](2);
        user5Proof[0] = bytes32(
            0x487a0fa9fe1271bede1abe958efd4a3e46c23bd75ee1766be76ac527effefdb2
        );
        user5Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );
        bytes32[] memory user6Proof = new bytes32[](2);
        user6Proof[0] = bytes32(
            0x214ce8fb7807e8a6d3aae20a0447e848c2b2676ee5ee6c7bd6badaed66a2f817
        );
        user6Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );

        uint256 user5Amount = 10;
        uint256 user5Value = tokenSale.PRESALE_PRICE() * user5Amount;
        uint256 user6Amount = 10;
        uint256 user6Value = tokenSale.PRESALE_PRICE() * user6Amount;

        vm.startPrank(user5);
        tokenSale.buyPresale{value: user5Value}(user5Proof, user5Amount);
        vm.stopPrank();

        assertTrue(tokenSale.presaleBalances(user5) == user5Amount);
        assertTrue(tokenSale.presaleBuyed() == user5Amount);
        assertTrue(
            address(user5).balance == 100000000000000000000 - user5Value
        );

        vm.startPrank(user6);
        tokenSale.buyPresale{value: tokenSale.PRESALE_PRICE() * user6Amount}(
            user6Proof,
            user6Amount
        );
        vm.stopPrank();

        assertTrue(tokenSale.presaleBalances(user6) == user6Amount);
        assertTrue(tokenSale.presaleBuyed() == user5Amount + user6Amount);
        assertTrue(
            address(user6).balance == 100000000000000000000 - user6Value
        );

        assertTrue(tokenSale.PRESALE_AMOUNT() - tokenSale.presaleBuyed() == 10);

        vm.prank(contractOwner);
        tokenSale.setStartPresale(false);
        assertTrue(tokenSale.isPresaleStarted() == false);

        emit log("-----> Presale Test (OKAY)");
        tSetTransferToPublic();
    }

    function tSetTransferToPublic() public {
        uint256 beforePublicAmount = tokenSale.PUBLICSALE_AMOUNT();

        vm.prank(contractOwner);
        tokenSale.setTransferToPublic();

        assertTrue(tokenSale.PUBLICSALE_AMOUNT() != beforePublicAmount);
        assertTrue(tokenSale.PUBLICSALE_AMOUNT() == beforePublicAmount + 10);

        emit log("-----> Set Transfer To Public Test (OKAY)");
        tBuyPublicsale();
    }

    function tBuyPublicsale() public {
        vm.prank(contractOwner);
        tokenSale.setStartPublicsale(true);

        assertTrue(tokenSale.isPublicsaleStarted() == true);

        uint256 user7Amount = 10;
        uint256 user7Value = tokenSale.PUBLICSALE_PRICE() * user7Amount;
        uint256 user8Amount = 10;
        uint256 user8Value = tokenSale.PUBLICSALE_PRICE() * user8Amount;

        vm.startPrank(user7);
        tokenSale.buyPublicsale{value: user7Value}(user7Amount);
        vm.stopPrank();

        assertTrue(tokenSale.publicsaleBalances(user7) == user7Amount);
        assertTrue(tokenSale.publicsaleBuyed() == user7Amount);
        assertTrue(
            address(user7).balance == 100000000000000000000 - user7Value
        );

        vm.startPrank(user8);
        tokenSale.buyPublicsale{value: user8Value}(user8Amount);
        vm.stopPrank();

        assertTrue(tokenSale.publicsaleBalances(user8) == user8Amount);
        assertTrue(tokenSale.publicsaleBuyed() == user7Amount + user8Amount);
        assertTrue(
            address(user8).balance == 100000000000000000000 - user8Value
        );

        assertTrue(
            tokenSale.PUBLICSALE_AMOUNT() - tokenSale.publicsaleBuyed() == 30
        );

        vm.prank(contractOwner);
        tokenSale.setStartPublicsale(false);
        assertTrue(tokenSale.isPublicsaleStarted() == false);

        emit log("-----> Publicsale Test (OKAY)");
        tClaimAirdrop();
    }

    function tClaimAirdrop() public {
        assertTrue(token.balanceOf(user1) == 0);

        uint256 firstBalance = tokenSale.airdropBalances(user1);
        uint256 perPeriodBalance = (firstBalance /
            tokenSale.AIRDROP_CLAIM_PERIOD()) * 10 ** 18;

        // 1. Period
        vm.warp(110);
        vm.prank(user1);
        tokenSale.claimAirdrop(1);
        assertTrue(token.balanceOf(user1) == perPeriodBalance);
        // 2. Period
        vm.warp(120);
        vm.prank(user1);
        tokenSale.claimAirdrop(2);
        assertTrue(token.balanceOf(user1) == perPeriodBalance * 2);
        // 3. Period
        vm.warp(130);
        vm.prank(user1);
        tokenSale.claimAirdrop(3);
        assertTrue(token.balanceOf(user1) == perPeriodBalance * 3);
        // 4. Period
        vm.warp(140);
        vm.prank(user1);
        tokenSale.claimAirdrop(4);
        assertTrue(token.balanceOf(user1) == perPeriodBalance * 4);
        // 5. Period
        vm.warp(150);
        vm.prank(user1);
        tokenSale.claimAirdrop(5);
        assertTrue(token.balanceOf(user1) == perPeriodBalance * 5);
        assertTrue(token.balanceOf(user1) == firstBalance * 10 ** 18);
        assertTrue(tokenSale.airdropBalances(user1) == 0);

        emit log("-----> Airdrop Claim Test (OKAY)");
        tClaimPresale();
    }

    function tClaimSeedsale() public {
        assertTrue(token.balanceOf(user3) == 0);

        uint256 firstBalance = tokenSale.seedsaleBalances(user3);
        uint256 perPeriodBalance = (firstBalance /
            tokenSale.SEEDSALE_CLAIM_PERIOD()) * 10 ** 18;

        // 1. Period
        vm.warp(210);
        vm.prank(user3);
        tokenSale.claimSeedsale(1);
        assertTrue(token.balanceOf(user3) == perPeriodBalance);
        // 2. Period
        vm.warp(220);
        vm.prank(user3);
        tokenSale.claimSeedsale(2);
        assertTrue(token.balanceOf(user3) == perPeriodBalance * 2);
        // 3. Period
        vm.warp(230);
        vm.prank(user3);
        tokenSale.claimSeedsale(3);
        assertTrue(token.balanceOf(user3) == perPeriodBalance * 3);
        // 4. Period
        vm.warp(240);
        vm.prank(user3);
        tokenSale.claimSeedsale(4);
        assertTrue(token.balanceOf(user3) == perPeriodBalance * 4);
        // 5. Period
        vm.warp(250);
        vm.prank(user3);
        tokenSale.claimSeedsale(5);
        assertTrue(token.balanceOf(user3) == perPeriodBalance * 5);
        assertTrue(token.balanceOf(user3) == firstBalance * 10 ** 18);
        assertTrue(tokenSale.seedsaleBalances(user3) == 0);

        emit log("-----> Seedsale Claim Test (OKAY)");
        tClaimPublicsale();
    }

    function tClaimPresale() public {
        assertTrue(token.balanceOf(user5) == 0);

        uint256 firstBalance = tokenSale.presaleBalances(user5);
        uint256 perPeriodBalance = (firstBalance /
            tokenSale.PRESALE_CLAIM_PERIOD()) * 10 ** 18;

        // 1. Period
        vm.warp(310);
        vm.prank(user5);
        tokenSale.claimPresale(1);
        assertTrue(token.balanceOf(user5) == perPeriodBalance);
        // 2. Period
        vm.warp(320);
        vm.prank(user5);
        tokenSale.claimPresale(2);
        assertTrue(token.balanceOf(user5) == perPeriodBalance * 2);
        // 3. Period
        vm.warp(330);
        vm.prank(user5);
        tokenSale.claimPresale(3);
        assertTrue(token.balanceOf(user5) == perPeriodBalance * 3);
        // 4. Period
        vm.warp(340);
        vm.prank(user5);
        tokenSale.claimPresale(4);
        assertTrue(token.balanceOf(user5) == perPeriodBalance * 4);
        // 5. Period
        vm.warp(350);
        vm.prank(user5);
        tokenSale.claimPresale(5);
        assertTrue(token.balanceOf(user5) == perPeriodBalance * 5);
        assertTrue(token.balanceOf(user5) == firstBalance * 10 ** 18);
        assertTrue(tokenSale.presaleBalances(user5) == 0);

        emit log("-----> Presale Claim Test (OKAY)");
        tClaimSeedsale();
    }

    function tClaimPublicsale() public {
        assertTrue(token.balanceOf(user7) == 0);

        uint256 firstBalance = tokenSale.publicsaleBalances(user7);
        uint256 perPeriodBalance = (firstBalance /
            tokenSale.PUBLICSALE_CLAIM_PERIOD()) * 10 ** 18;

        // 1. Period
        vm.warp(410);
        vm.prank(user7);
        tokenSale.claimPublicsale(1);
        assertTrue(token.balanceOf(user7) == perPeriodBalance);
        // 2. Period
        vm.warp(420);
        vm.prank(user7);
        tokenSale.claimPublicsale(2);
        assertTrue(token.balanceOf(user7) == perPeriodBalance * 2);
        // 3. Period
        vm.warp(430);
        vm.prank(user7);
        tokenSale.claimPublicsale(3);
        assertTrue(token.balanceOf(user7) == perPeriodBalance * 3);
        // 4. Period
        vm.warp(440);
        vm.prank(user7);
        tokenSale.claimPublicsale(4);
        assertTrue(token.balanceOf(user7) == perPeriodBalance * 4);
        // 5. Period
        vm.warp(450);
        vm.prank(user7);
        tokenSale.claimPublicsale(5);
        assertTrue(token.balanceOf(user7) == perPeriodBalance * 5);
        assertTrue(token.balanceOf(user7) == firstBalance * 10 ** 18);
        assertTrue(tokenSale.publicsaleBalances(user7) == 0);

        emit log("-----> Publicsale Clain Test (OKAY)");
        tWithdrawCoin();
    }

    function tWithdrawCoin() public {
        uint256 beforeOwnerBalance = address(contractOwner).balance;
        uint256 beforeContractBalance = address(tokenSale).balance;
        vm.prank(contractOwner);
        tokenSale.withdrawCoin();
        assertTrue(
            address(contractOwner).balance ==
                beforeOwnerBalance + beforeContractBalance
        );
        assertTrue(address(tokenSale).balance == 0);

        emit log("-----> Withdraw Coin Test (OKAY)");
        tWithdrawToken();
    }

    function tWithdrawToken() public {
        uint256 beforeOwnerBalance = token.balanceOf(contractOwner);
        uint256 beforeContractBalance = token.balanceOf(address(tokenSale));
        vm.prank(contractOwner);
        tokenSale.withdrawToken();
        assertTrue(
            token.balanceOf(contractOwner) ==
                beforeOwnerBalance + beforeContractBalance
        );
        assertTrue(token.balanceOf(address(tokenSale)) == 0);

        emit log("-----> Withdraw Token Test (OKAY)");
    }
}
