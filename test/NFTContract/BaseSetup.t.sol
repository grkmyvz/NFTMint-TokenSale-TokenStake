// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../lib/forge-std/src/Test.sol";
import "../../src/NFTContract.sol";
import {Users} from "./utils/Users.sol";

contract BaseSetup is Test {
    NFTName public nftContract;

    Users internal users;

    uint256 public constant WALLET_BALANCE = 100 ether;

    modifier mintedForOwner(uint256 _qty) {
        vm.prank(users.owner);
        nftContract.ownerMint(_qty);
        _;
    }

    modifier activeFreelistRoot() {
        vm.prank(users.owner);
        nftContract.setFreelistRoot(
            bytes32(
                0x6a1408a6fc9beeb316f1874dc3b5db4cab44a8a0c5d7333a2c71cbc6d8433ccc
            )
        );
        _;
    }

    modifier activeWhitelistRoot() {
        vm.prank(users.owner);
        nftContract.setWhitelistRoot(
            bytes32(
                0x1c745257718f2f75dd8a6584b3f9b5f3ccf25dfcc4275af8080daba3a7211dc9
            )
        );
        _;
    }

    constructor() {}

    function setUp() public {
        users = Users({
            owner: createUser("Owner"),
            freeMinter: createUser("FreeMinter"),
            whitelistMinter: createUser("WhitelistMinter"),
            publicMinter: createUser("PublicMinter"),
            guest: createUser("Guest")
        });

        vm.prank(users.owner);
        nftContract = new NFTName();
    }

    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({account: user, newBalance: WALLET_BALANCE});
        return user;
    }

    function test_ShouldBeSetup() public {
        assertEq(address(users.owner).balance, WALLET_BALANCE);
        assertEq(address(users.freeMinter).balance, WALLET_BALANCE);
        assertEq(address(users.whitelistMinter).balance, WALLET_BALANCE);
        assertEq(address(users.publicMinter).balance, WALLET_BALANCE);
        assertEq(address(users.guest).balance, WALLET_BALANCE);
        assertTrue(address(nftContract) != address(0));

        emit log_named_address("Owner Address", address(users.owner));
        emit log_named_address("FreeMinter Address", address(users.freeMinter));
        emit log_named_address(
            "WhitelistMinter Address",
            address(users.whitelistMinter)
        );
        emit log_named_address(
            "PublicMinter Address",
            address(users.publicMinter)
        );
        emit log_named_address("Guest Address", address(users.guest));
        emit log_named_address("NFTContract Address", address(nftContract));
    }
}
