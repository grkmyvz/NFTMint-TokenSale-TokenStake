// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../src/NFTContract.sol";

import {BaseTest} from "./BaseTest.sol";
import {Utilities} from "./utils/Utilities.sol";

contract NFTContractAudit is BaseTest {
    NFTName public nftContract;

    address public contractOwner;
    address public user1;
    address public user2;
    address public user3;
    address public member1;

    address public freeAddress = 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF;
    address public whitelistAddress =
        0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69;
    address public publicAddress = 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718;

    uint256 public constant WALLET_BALANCE = 100 ether;

    constructor() {
        string[] memory labels = new string[](5);
        labels[0] = "contractOwner";
        labels[1] = "user1";
        labels[2] = "user2";
        labels[3] = "user3";
        labels[4] = "member1";

        preSetup(5, labels);
    }

    function setUp() public override {
        super.setUp();

        contractOwner = users[0];
        user1 = users[1];
        user2 = users[2];
        user3 = users[3];
        member1 = users[4];

        vm.prank(contractOwner);
        nftContract = new NFTName();

        vm.deal(freeAddress, WALLET_BALANCE);
        vm.label(freeAddress, "freeAddress");
        vm.deal(whitelistAddress, WALLET_BALANCE);
        vm.label(whitelistAddress, "whitelistAddress");
        vm.deal(publicAddress, WALLET_BALANCE);
        vm.label(publicAddress, "publicAddress");

        // emit log_named_address("Contract Address", address(nftContract));
        // emit log_named_address("Contract Owner", contractOwner);
        // emit log_named_address("User 1", user1);
        // emit log_named_address("User 2", user2);
        // emit log_named_address("User 3", user3);
        // emit log_named_address("Member 1", member1);
    }

    function testSetup() public {
        emit log_named_address("Contract Address", address(nftContract));
        emit log_named_address("Contract Owner", contractOwner);
        emit log_named_address("User 1", user1);
        emit log_named_address("User 2", user2);
        emit log_named_address("User 3", user3);
        emit log_named_address("Member 1", member1);
    }

    function test_baseURI() public {
        assertEq(nftContract.BASE_URL(), "https://localhost/");
    }

    function test_setBaseURl() public {
        assertEq(nftContract.BASE_URL(), "https://localhost/");
        vm.prank(contractOwner);
        nftContract.setBaseUrl("https://test.com/");
        assertEq(nftContract.BASE_URL(), "https://test.com/");
    }

    function test_isMinted() public {
        assertEq(nftContract.isMinted(0), false);
        vm.prank(contractOwner);
        nftContract.ownerMint(1);
        assertEq(nftContract.isMinted(0), true);
    }

    function test_setMintStatus() public {
        vm.startPrank(contractOwner);
        assertEq(nftContract.MINT_STATUS(), false);
        nftContract.setMintStatus(true);
        assertEq(nftContract.MINT_STATUS(), true);
        vm.stopPrank();
    }

    function test_Revert_setTime_InvalidFreeMintTime() public {
        vm.prank(contractOwner);
        vm.expectRevert(NFTName.InvalidFreeMintTime.selector);
        nftContract.setTimes(5, 3, 2, 5, 6);
    }

    function test_Revert_setTime_InvalidWhitelistTime() public {
        vm.prank(contractOwner);
        vm.expectRevert(NFTName.InvalidWhitelistMintTime.selector);
        nftContract.setTimes(5, 6, 7, 5, 6);
    }

    function test_SetPrice() public {
        vm.prank(contractOwner);
        nftContract.setPrices(100, 200);

        assertEq(nftContract.WHITELIST_PRICE(), 100);
        assertEq(nftContract.PUBLIC_PRICE(), 200);
    }

    function test_Revert_SetPrice() public {
        vm.warp(nftContract.WHITELIST_START() + 1);
        vm.prank(contractOwner);
        vm.expectRevert(NFTName.CanNotChangePrice.selector);
        nftContract.setPrices(200, 100);
    }

    function test_Revert_ownerMint_InvalidQuantity() public {
        vm.prank(contractOwner);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.ownerMint(0);
    }

    function test_Revert_ownerMint_OverflowMaxSupply() public {
        // nftContract.ownerMint(nftContract.MAX_SUPPLY() + 1);
        uint256 amount = nftContract.MAX_SUPPLY();
        emit log_named_uint("MAX_SUPPLY", amount);
        vm.prank(contractOwner);
        vm.expectRevert(NFTName.OwerflowMaxSupply.selector);
        nftContract.ownerMint(amount + 1);
    }

    modifier ownerMinted() {
        vm.prank(contractOwner);
        nftContract.ownerMint(1);
        _;
    }

    function test_ownerMint() public {
        uint256 preBalance = nftContract.balanceOf(contractOwner);
        vm.prank(contractOwner);
        nftContract.ownerMint(1);
        uint256 postBalance = nftContract.balanceOf(contractOwner);
        assertEq(preBalance + 1, postBalance);
    }

    function test_getTokenListByOwner() public {
        uint256[] memory tokenList = nftContract.getTokenListByOwner(
            contractOwner
        );
        assertEq(tokenList.length, 0);
        vm.startPrank(contractOwner);
        nftContract.ownerMint(3);
        vm.stopPrank();
        tokenList = nftContract.getTokenListByOwner(contractOwner);
        assertEq(tokenList.length, 3);
        assertEq(tokenList[0], 0);
        assertEq(tokenList[1], 1);
        assertEq(tokenList[2], 2);
    }

    function test_tokenURI() public ownerMinted {
        string memory tokenURI = nftContract.tokenURI(0);
        assertEq(tokenURI, "https://localhost/0.json");
    }

    function test_set_and_getTokenURI() public ownerMinted {
        string memory tokenURI = nftContract.tokenURI(0);
        assertEq(tokenURI, "https://localhost/0.json");
        vm.prank(contractOwner);
        nftContract.setBaseUrl("https://test.com/");
        tokenURI = nftContract.tokenURI(0);
        assertEq(tokenURI, "https://test.com/0.json");
    }

    modifier setFreelistRoot() {
        vm.prank(contractOwner);
        nftContract.setFreelistRoot(
            bytes32(
                0x4c2793909c6fd3832188b7b5693cb1fd466066cb37e4366c1f8bc6b7db24d9d7
            )
        );
        _;
    }

    modifier setWhitelistRoot() {
        vm.prank(contractOwner);
        nftContract.setWhitelistRoot(
            bytes32(
                0x4c2793909c6fd3832188b7b5693cb1fd466066cb37e4366c1f8bc6b7db24d9d7
            )
        );
        _;
    }

    function test_setFreelistRoot() public setFreelistRoot {
        assertEq(
            nftContract.freeMerkleRoot(),
            bytes32(
                0x4c2793909c6fd3832188b7b5693cb1fd466066cb37e4366c1f8bc6b7db24d9d7
            )
        );
    }

    function test_setWhitelistRoot() public setWhitelistRoot {
        assertEq(
            nftContract.whitelistMerkleRoot(),
            bytes32(
                0x4c2793909c6fd3832188b7b5693cb1fd466066cb37e4366c1f8bc6b7db24d9d7
            )
        );
    }

    function test_Revert_freeMint_FreeMintNotStarted() public setFreelistRoot {
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
        vm.prank(freeAddress);
        vm.expectRevert(NFTName.FreeMintNotStarted.selector);
        nftContract.freeMint(proof, 0);
    }

    function test_Revert_freeMint_MintingStopped() public setFreelistRoot {
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
        vm.warp(nftContract.FREE_START());
        assertEq(nftContract.MINT_STATUS(), false);
        vm.prank(contractOwner);
        nftContract.setMintStatus(true);
        vm.prank(freeAddress);
        vm.expectRevert(NFTName.MintingStopped.selector);
        nftContract.freeMint(proof, 0);
    }

    function test_Revert_freeMint_FreeMintFinished() public setFreelistRoot {
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
        vm.warp(nftContract.FREE_STOP() + 1);
        vm.prank(freeAddress);
        vm.expectRevert(NFTName.FreeMintFinished.selector);
        nftContract.freeMint(proof, 0);
    }

    function test_Revert_freeMint_InvalidQuantity() public setFreelistRoot {
        vm.warp(nftContract.FREE_START());
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
        vm.prank(freeAddress);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.freeMint(proof, 0);
    }

    function test_Revert_freeMint_OverflowMaxSupply() public setFreelistRoot {
        vm.warp(nftContract.FREE_START());
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
        uint256 amount = nftContract.MAX_SUPPLY() + 1;
        vm.prank(freeAddress);
        vm.expectRevert(NFTName.OwerflowMaxSupply.selector);
        nftContract.freeMint(proof, amount);
    }

    function test_Revert_freeMint_HaveNotEligible() public setFreelistRoot {
        vm.warp(nftContract.FREE_START());
        bytes32[] memory proof = new bytes32[](4);
        vm.prank(freeAddress);
        vm.expectRevert(NFTName.HaveNotEligible.selector);
        nftContract.freeMint(proof, 1);
    }

    function test_Revert_freeMint_OverflowQuantity() public setFreelistRoot {
        vm.warp(nftContract.FREE_START());
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
        uint256 amount = nftContract.FREE_PER_WALLET();
        vm.startPrank(freeAddress);
        nftContract.freeMint(proof, amount);
        vm.expectRevert(NFTName.FreeMintLimitExceeded.selector);
        nftContract.freeMint(proof, 1);
        vm.stopPrank();
    }

    function test_freeMint_increasesBalance() public setFreelistRoot {
        vm.warp(nftContract.FREE_START());
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

        uint256 preBalance = nftContract.balanceOf(freeAddress);
        vm.prank(freeAddress);
        nftContract.freeMint(proof, 1);
        uint256 postBalance = nftContract.balanceOf(freeAddress);
        assertEq(preBalance + 1, postBalance);
    }

    function test_Revert_whitelistMint_WhitelistMintNotStarted()
        public
        setWhitelistRoot
    {
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
        vm.warp(nftContract.WHITELIST_START() - 1);
        vm.prank(whitelistAddress);
        vm.expectRevert(NFTName.WhitelistMintNotStarted.selector);
        nftContract.whitelistMint(proof, 0);
    }

    function test_Revert_whitelistMint_WhitelistMintFinished()
        public
        setWhitelistRoot
    {
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
        vm.warp(nftContract.WHITELIST_STOP() + 1);
        vm.prank(whitelistAddress);
        vm.expectRevert(NFTName.WhitelistMintFinished.selector);
        nftContract.whitelistMint(proof, 0);
    }

    function test_Revert_whitelistMint_MintingStopped()
        public
        setWhitelistRoot
    {
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

        vm.warp(nftContract.WHITELIST_START());
        assertEq(nftContract.MINT_STATUS(), false);
        vm.prank(contractOwner);
        nftContract.setMintStatus(true);
        vm.prank(whitelistAddress);
        vm.expectRevert(NFTName.MintingStopped.selector);
        nftContract.whitelistMint(proof, 0);
    }

    function test_Revert_whitelistMint_InvalidQuantity()
        public
        setWhitelistRoot
    {
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

        vm.warp(nftContract.WHITELIST_START());
        vm.prank(whitelistAddress);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.whitelistMint(proof, 0);
    }

    function test_Revert_whitelistMint_OverflowMaxSupply()
        public
        setWhitelistRoot
    {
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

        uint256 amount = nftContract.MAX_SUPPLY() + 1;
        vm.warp(nftContract.WHITELIST_START());
        vm.prank(whitelistAddress);
        vm.expectRevert(NFTName.OwerflowMaxSupply.selector);
        nftContract.whitelistMint(proof, amount);
    }

    function test_Revert_whitelistMint_HaveNotEligible()
        public
        setWhitelistRoot
    {
        bytes32[] memory proof = new bytes32[](4);

        vm.warp(nftContract.WHITELIST_START());
        vm.prank(whitelistAddress);
        vm.expectRevert(NFTName.HaveNotEligible.selector);
        nftContract.whitelistMint(proof, 1);
    }

    function test_Revert_whitelistMint_OverflowQuantity()
        public
        setWhitelistRoot
    {
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

        uint256 amount = nftContract.WHITELIST_PER_WALLET();
        uint256 totalValue = nftContract.WHITELIST_PRICE() * amount;
        vm.warp(nftContract.WHITELIST_START());
        vm.startPrank(whitelistAddress);
        nftContract.whitelistMint{value: totalValue}(proof, amount);
        vm.expectRevert(NFTName.WhitelistMintLimitExceeded.selector);
        nftContract.whitelistMint(proof, 1);
    }

    function test_Revert_whitelistMint_InsufficientBalance()
        public
        setWhitelistRoot
    {
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

        uint256 amount = nftContract.WHITELIST_PER_WALLET();
        uint256 totalValue = nftContract.WHITELIST_PRICE() * amount;
        vm.warp(nftContract.WHITELIST_START());
        vm.startPrank(whitelistAddress);
        vm.expectRevert(NFTName.InsufficientBalance.selector);
        nftContract.whitelistMint{value: totalValue - 1}(proof, amount);
        // nftContract.whitelistMint(proof, 1);
    }

    function test_whitelistMint_increasesBalance() public setWhitelistRoot {
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
        assertEq(nftContract.balanceOf(whitelistAddress), 0);
        uint256 preBalance = nftContract.balanceOf(whitelistAddress);
        uint256 amount = nftContract.WHITELIST_PER_WALLET();
        uint256 totalValue = nftContract.WHITELIST_PRICE() * amount;
        vm.warp(nftContract.WHITELIST_START());
        vm.startPrank(whitelistAddress);
        nftContract.whitelistMint{value: totalValue}(proof, amount);
        uint256 postBalance = nftContract.balanceOf(whitelistAddress);
        assertEq(preBalance + amount, postBalance);
    }

    function test_Revert_publicMint_PublicMintNotStarted() public {
        vm.prank(publicAddress);
        vm.expectRevert(NFTName.PublicMintNotStarted.selector);
        nftContract.publicMint(0);
    }

    function test_publicMint_PublicMintFinished() public {
        vm.warp(nftContract.PUBLIC_START());
        //assertEq(block.timestamp > nftContract.PUBLIC_STOP(), true);
        uint256 amount = nftContract.PUBLIC_PER_WALLET();
        uint256 totalValue = nftContract.PUBLIC_PRICE() * amount;
        assertEq(nftContract.balanceOf(publicAddress), 0);
        uint256 preBalance = nftContract.balanceOf(publicAddress);
        vm.startPrank(publicAddress);

        // vm.expectRevert(bytes("PublicMintFinished"));
        nftContract.publicMint{value: totalValue}(amount);
        uint256 postBalance = nftContract.balanceOf(publicAddress);
        assertEq(preBalance + amount, postBalance);
    }

    function test_Revert_publicMint_InvalidQuantity() public {
        vm.warp(nftContract.PUBLIC_START());
        vm.prank(publicAddress);
        vm.expectRevert(NFTName.InvalidAmount.selector);
        nftContract.publicMint(0);
    }

    function test_Revert_publicMint_OverflowMaxSupply() public {
        vm.warp(nftContract.PUBLIC_START());
        uint256 amount = nftContract.MAX_SUPPLY() + 1;
        vm.prank(publicAddress);
        vm.expectRevert(NFTName.OwerflowMaxSupply.selector);
        nftContract.publicMint(amount);
    }

    function test_Revert_publicMint_OverflowQuantity() public {
        vm.warp(nftContract.PUBLIC_START());
        uint256 amount = nftContract.PUBLIC_PER_WALLET();
        uint256 totalValue = nftContract.PUBLIC_PRICE() * amount;
        vm.startPrank(publicAddress);
        nftContract.publicMint{value: totalValue}(amount);
        vm.expectRevert(NFTName.PublicMintLimitExceeded.selector);
        nftContract.publicMint(amount);
        vm.stopPrank();
    }

    function test_Revert_publicMint_InsufficientBalance() public {
        vm.warp(nftContract.PUBLIC_START());
        uint256 amount = nftContract.PUBLIC_PER_WALLET();
        uint256 totalValue = nftContract.PUBLIC_PRICE() * amount;
        vm.startPrank(publicAddress);
        vm.expectRevert(NFTName.InsufficientBalance.selector);
        nftContract.publicMint{value: totalValue - 1}(amount);
        // nftContract.publicMint(amount);
        vm.stopPrank();
    }

    function test_publicMint_increasesBalance() public {
        vm.warp(nftContract.PUBLIC_START());
        uint256 amount = nftContract.PUBLIC_PER_WALLET();
        uint256 totalValue = nftContract.PUBLIC_PRICE() * amount;
        assertEq(nftContract.balanceOf(publicAddress), 0);
        uint256 preBalance = nftContract.balanceOf(publicAddress);
        vm.startPrank(publicAddress);
        nftContract.publicMint{value: totalValue}(amount);
        uint256 postBalance = nftContract.balanceOf(publicAddress);
        assertEq(preBalance + amount, postBalance);
    }

    function test_Revert_multipleTransferToZeroAddress() public {
        uint256[] memory _tokenId = new uint256[](1);
        _tokenId[0] = 1;
        vm.expectRevert(NFTName.InvalidAddress.selector);
        nftContract.multipleTransfer(address(0), _tokenId);
    }

    function test_Revert_multipleTransferDoesntHave() public ownerMinted {
        // first mint token
        uint256[] memory _tokenId = new uint256[](1);
        _tokenId[0] = 0;
        vm.prank(user1);
        vm.expectRevert(NFTName.YouNotTokenHolder.selector);
        nftContract.multipleTransfer(address(1), _tokenId);
    }

    function test_withdrawMoney() public {
        vm.warp(nftContract.PUBLIC_START());
        uint256 amount = nftContract.PUBLIC_PER_WALLET();
        uint256 totalValue = nftContract.PUBLIC_PRICE() * amount;
        assertEq(nftContract.balanceOf(publicAddress), 0);
        uint256 preBalance = nftContract.balanceOf(publicAddress);
        vm.startPrank(publicAddress);
        nftContract.publicMint{value: totalValue}(amount);
        uint256 postBalance = nftContract.balanceOf(publicAddress);
        assertEq(preBalance + amount, postBalance);
        vm.stopPrank();

        uint256 preBal = address(contractOwner).balance;
        vm.prank(contractOwner);
        nftContract.withdrawMoney();
        assertEq(preBal + totalValue, address(contractOwner).balance);
    }

    function test_Revert_withdrawMoney_WithdrawalFailed() public {
        vm.warp(nftContract.PUBLIC_START());
        uint256 amount = nftContract.PUBLIC_PER_WALLET();
        uint256 totalValue = nftContract.PUBLIC_PRICE() * amount;
        assertEq(nftContract.balanceOf(publicAddress), 0);
        uint256 preBalance = nftContract.balanceOf(publicAddress);
        vm.startPrank(publicAddress);
        nftContract.publicMint{value: totalValue}(amount);
        uint256 postBalance = nftContract.balanceOf(publicAddress);
        assertEq(preBalance + amount, postBalance);
        vm.stopPrank();

        vm.startPrank(contractOwner);
        Wallet walletContract = new Wallet(address(nftContract));
        nftContract.transferOwnership(address(walletContract));
        vm.expectRevert(NFTName.WithdrawalFailed.selector);
        walletContract.withdraw();
    }
}

contract Wallet {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function withdraw() public {
        NFTName(payable(target)).withdrawMoney();
    }

    receive() external payable {
        revert("do not send ether");
    }
}
