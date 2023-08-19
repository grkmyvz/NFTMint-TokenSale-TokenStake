// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/NFTContract.sol";

contract NFTContractTest is Test {
    NFTName public nftContract;

    address contractOwner;
    address user1;
    address user2;
    address user3;
    address member1;

    function setUp() public {
        contractOwner = vm.addr(1);
        user1 = vm.addr(2);
        user2 = vm.addr(3);
        user3 = vm.addr(4);
        member1 = vm.addr(5);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
        vm.deal(member1, 100 ether);
        vm.prank(contractOwner);
        nftContract = new NFTName();
        emit log_named_address("Contract Address", address(nftContract));
        emit log_named_address("Contract Owner", contractOwner);
        emit log_named_address("User 1", user1);
        emit log_named_address("User 2", user2);
        emit log_named_address("User 3", user3);
        emit log_named_address("Member 1", member1);
    }

    function testContract() public {
        assertTrue(address(this) != address(0));
        assertTrue(address(nftContract) != address(0));
        assertTrue(address(contractOwner) != address(0));
        assertTrue(address(user1) != address(0));
        assertTrue(address(user2) != address(0));
        assertTrue(address(user3) != address(0));
        assertTrue(address(member1) != address(0));

        assertTrue(address(user1).balance == 100000000000000000000);
        assertTrue(address(user2).balance == 100000000000000000000);
        assertTrue(address(user3).balance == 100000000000000000000);
        assertTrue(address(member1).balance == 100000000000000000000);

        emit log("-----> Addresses Test (OKAY)");
        tOwnerMint();
    }

    // Only owner test (okay)
    // Zero params test (okay)
    // Overflow max supply test (okay)
    // All test (okay) //
    function tOwnerMint() public {
        vm.prank(contractOwner);
        nftContract.ownerMint(20);

        assertTrue(nftContract.balanceOf(contractOwner) == 20);

        emit log("-----> ownerMint Test (OKAY)");
        tSetFreelistRoot();
    }

    // Only owner test (okay)
    // All test (okay) //
    function tSetFreelistRoot() public {
        vm.prank(contractOwner);
        nftContract.setFreelistRoot(
            bytes32(
                0x4c2793909c6fd3832188b7b5693cb1fd466066cb37e4366c1f8bc6b7db24d9d7
            )
        );

        emit log("-----> setFreelistRoot Test (OKAY)");
        tSetWhitelistRoot();
    }

    // Only owner test (okay)
    // All test (okay) //
    function tSetWhitelistRoot() public {
        vm.prank(contractOwner);
        nftContract.setWhitelistRoot(
            bytes32(
                0x4c2793909c6fd3832188b7b5693cb1fd466066cb37e4366c1f8bc6b7db24d9d7
            )
        );

        emit log("-----> setWhitelistRoot Test (OKAY)");
        tFreeMint();
    }

    // Free mint time test (okay)
    // Zero params test (okay)
    // Overflow max supply test (okay)
    // Merkle tree proof test (okay)
    // Overflow per wallet test (okay)
    // All test (okay) //
    function tFreeMint() public {
        vm.warp(2);
        bytes32[] memory proof = new bytes32[](4);
        proof[0] = bytes32(
            0x1bec7c333d3d0c3eef8c6199a402856509c3f869d25408cc1cc2208d0371db0e
        );
        proof[1] = bytes32(
            0x25ce6c3168e514002467697b04de7166d75489216f9e90c2e1e13fdfd35ea793
        );
        proof[2] = bytes32(
            0x3fc22262b3e4fff148ec32df7ae1b592f2ad3ac501813566d932063cdf134fe1
        );
        proof[3] = bytes32(
            0x154fba61f817ed493b12b0c1f9cdadc21f1846ff3145cc9fb5dfe99736335e3a
        );
        vm.prank(user1);
        nftContract.freeMint(proof, 1);

        assertTrue(nftContract.balanceOf(user1) == 1);

        emit log("-----> freeMint Test (OKAY)");
        tWlMint();
    }

    // Whitelist mint time test (okay)
    // Zero params test (okay)
    // Overflow max supply test (okay)
    // Merkle tree proof test (okay)
    // Overflow per wallet test (okay)
    // Price test (okay)
    // All test (okay) //
    function tWlMint() public {
        vm.warp(4);
        bytes32[] memory proof = new bytes32[](4);
        proof[0] = bytes32(
            0x94a6fc29a44456b36232638a7042431c9c91b910df1c52187179085fac1560e9
        );
        proof[1] = bytes32(
            0x25ce6c3168e514002467697b04de7166d75489216f9e90c2e1e13fdfd35ea793
        );
        proof[2] = bytes32(
            0x3fc22262b3e4fff148ec32df7ae1b592f2ad3ac501813566d932063cdf134fe1
        );
        proof[3] = bytes32(
            0x154fba61f817ed493b12b0c1f9cdadc21f1846ff3145cc9fb5dfe99736335e3a
        );
        vm.prank(user2);
        nftContract.wlMint{value: 1 ether}(proof, 10);

        assertTrue(nftContract.balanceOf(user2) == 10);

        emit log("-----> whitelistMint Test (OKAY)");
        tPublicMint();
    }

    // Public mint time test (okay)
    // Zero params test (okay)
    // Overflow max supply test (okay)
    // Overflow per wallet test (okay)
    // Price test (okay)
    // All test (okay) //
    function tPublicMint() public {
        vm.warp(7);
        vm.prank(user3);
        nftContract.publicMint{value: 1 ether}(5);

        assertTrue(nftContract.balanceOf(user3) == 5);

        emit log("-----> publicMint Test (OKAY)");
        tSetTimes();
    }

    // Only owner test (okay)
    // Time control test (okay)
    // All test (okay) //
    function tSetTimes() public {
        vm.prank(contractOwner);
        nftContract.setTimes(11, 21, 31, 41, 51, 61);

        emit log("-----> setTimes Test (OKAY)");
        tGetTimes();
    }

    // Get times test (okay)
    function tGetTimes() public {
        (
            uint256 freeStart,
            uint256 freeStop,
            uint256 wlStart,
            uint256 wlStop,
            uint256 publicStart,
            uint256 publicStop
        ) = nftContract.getTimes();

        assert(freeStart == 11);
        assert(freeStop == 21);
        assert(wlStart == 31);
        assert(wlStop == 41);
        assert(publicStart == 51);
        assert(publicStop == 61);

        emit log("-----> getTimes Test (OKAY)");
        tMaxSupply();
        // tSetMintStop();
    }

    // Only owner test (okay)
    // Free mint stop test (okay)
    // Whitelist mint stop test (okay)
    // Public mint stop test (okay)
    // All test (okay) //
    /* function tSetMintStop() public {
        vm.prank(contractOwner);
        nftContract.setMintStop(true);

        vm.warp(6);
        bytes32[] memory proof = new bytes32[](4);
        proof[0] = bytes32(
            0x94a6fc29a44456b36232638a7042431c9c91b910df1c52187179085fac1560e9
        );
        proof[1] = bytes32(
            0x25ce6c3168e514002467697b04de7166d75489216f9e90c2e1e13fdfd35ea793
        );
        proof[2] = bytes32(
            0x3fc22262b3e4fff148ec32df7ae1b592f2ad3ac501813566d932063cdf134fe1
        );
        proof[3] = bytes32(
            0x154fba61f817ed493b12b0c1f9cdadc21f1846ff3145cc9fb5dfe99736335e3a
        );
        vm.prank(user2);
        nftContract.wlMint{value: 1 ether}(proof, 5);

        emit log("-----> mintStop Test (OKAY)");
        tMaxSupply();
    } */

    // Max supply test (okay)
    function tMaxSupply() public {
        vm.prank(contractOwner);
        nftContract.ownerMint(964);

        assertTrue(nftContract.balanceOf(contractOwner) == 984);
        assertTrue(nftContract.totalSupply() == 1000);

        emit log("-----> maxSupply Test (OKAY)");
        tMultipleTransfer();
    }

    // Multiple transfer time test (okay)
    function tMultipleTransfer() public {
        vm.prank(contractOwner);
        uint256[] memory ids = new uint256[](4);
        ids[0] = 0;
        ids[1] = 1;
        ids[2] = 5;
        ids[3] = 9;
        nftContract.multipleTransfer(member1, ids);

        assertTrue(nftContract.balanceOf(member1) == 4);
        assertTrue(nftContract.balanceOf(contractOwner) == 980);

        emit log("-----> multipleTransfer Test (OKAY)");
        tWithdrawal();
    }

    // Withdrawal time test (okay)
    function tWithdrawal() public {
        emit log_named_uint(
            "Before Withdrawal (Contract)",
            address(nftContract).balance
        );
        emit log_named_uint("Before Withdrawal (Owner)", contractOwner.balance);
        vm.prank(contractOwner);
        nftContract.withdrawMoney();
        emit log_named_uint(
            "After Withdrawal (Contract)",
            address(nftContract).balance
        );
        emit log_named_uint("After Withdrawal (Owner)", contractOwner.balance);

        emit log("-----> withdrawal Test (OKAY)");
        tContractDetail();
    }

    function tContractDetail() public {
        emit log("#### Contract Details ####");
        emit log_named_string("Contract Name", nftContract.name());
        emit log_named_string("Contract Symbol", nftContract.symbol());
        emit log_named_uint("Contract Total Supply", nftContract.totalSupply());
        emit log_named_address("Contract Owner", nftContract.owner());
    }
}
