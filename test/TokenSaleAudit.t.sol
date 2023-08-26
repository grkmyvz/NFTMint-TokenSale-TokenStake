// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/TokenSale.sol";

contract AuditTokenSaleTest is Test {
    MyToken public token;
    TokenSale public tokenSale;

    uint256 public constant USER_BALANCE = 100 ether;
    uint256 public constant TOTAL_TOKEN_AMOUNT = 110 ether;
    uint256 public TOKEN_TOTAL_SUPPLY;

    address public user;
    address public contractOwner;
    address public airdropAddress1 = 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF;
    address public airdropAddress2 = 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69;
    address public seedSaleAddress1 = 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718;
    address public seedSaleAddress2 = 0xe1AB8145F7E55DC933d51a18c793F901A3A0b276;
    address public presaleAddress1 = 0xE57bFE9F44b819898F47BF37E5AF72a0783e1141;
    address public presaleAddress2 = 0xd41c057fd1c78805AAC12B0A94a405c0461A6FBb;
    address public publicSaleAddress1 = makeAddr("publicSaleAddress1");
    address public publicSaleAddress2 = makeAddr("publicSaleAddress2");

    function setUp() public {
        user = makeAddr("user");
        contractOwner = makeAddr("contractOwner");

        vm.deal(user, USER_BALANCE);
        vm.deal(contractOwner, USER_BALANCE);

        vm.deal(airdropAddress1, USER_BALANCE);
        vm.label(airdropAddress1, "airdropAddress1");
        vm.deal(airdropAddress2, USER_BALANCE);
        vm.label(airdropAddress2, "airdropAddress2");

        vm.deal(seedSaleAddress1, USER_BALANCE);
        vm.label(seedSaleAddress1, "seedSaleAddress1");
        vm.deal(seedSaleAddress2, USER_BALANCE);
        vm.label(seedSaleAddress2, "seedSaleAddress2");

        vm.deal(presaleAddress1, USER_BALANCE);
        vm.label(presaleAddress1, "presaleAddress1");
        vm.deal(presaleAddress2, USER_BALANCE);
        vm.label(presaleAddress2, "presaleAddress2");

        vm.deal(publicSaleAddress1, USER_BALANCE);
        vm.deal(publicSaleAddress2, USER_BALANCE);
    }

    //////////////////////////
    // Deployment           //
    //////////////////////////
    function test_correctlySetup() public successfullyDeploy setSendToken {
        assertEq(contractOwner.balance, USER_BALANCE);
        assertEq(airdropAddress1.balance, USER_BALANCE);
        assertEq(airdropAddress2.balance, USER_BALANCE);
        assertEq(seedSaleAddress1.balance, USER_BALANCE);
        assertEq(seedSaleAddress2.balance, USER_BALANCE);

        assertEq(token.balanceOf(address(tokenSale)), TOTAL_TOKEN_AMOUNT);
        assertEq(token.balanceOf(contractOwner), TOKEN_TOTAL_SUPPLY - TOTAL_TOKEN_AMOUNT);

        assertEq(tokenSale.isTokenBalanceOk(), true);
        assertEq(tokenSale.isAirdropStarted(), false);
        assertEq(tokenSale.isPresaleStarted(), false);
        assertEq(tokenSale.isSeedsaleStarted(), false);
        assertEq(tokenSale.isPublicsaleStarted(), false);
    }

    modifier successfullyDeploy() {
        vm.startPrank(contractOwner);

        token = new MyToken();
        tokenSale = new TokenSale(address(token));

        vm.stopPrank();
        _;
    }

    function test_Deployment() public successfullyDeploy {}

    function test_Revert_Deployment() public {
        vm.startPrank(contractOwner);
        token = new MyToken();
        vm.expectRevert(bytes("InvalidTokenAddress"));
        tokenSale = new TokenSale(address(0));
        vm.stopPrank();
    }

    //////////////////////////
    // setSendTokens        //
    //////////////////////////
    function test_Revert_whensetSendTokenIncorrectAmount() public successfullyDeploy {
        vm.startPrank(contractOwner);
        uint256 amount = TOTAL_TOKEN_AMOUNT - 1;
        token.approve(address(tokenSale), amount);
        vm.expectRevert(bytes("InvalidAmount"));
        tokenSale.setSendTokens(amount);
        vm.stopPrank();
    }

    modifier setSendToken() {
        vm.startPrank(contractOwner);

        TOKEN_TOTAL_SUPPLY = token.totalSupply();

        token.approve(address(tokenSale), TOTAL_TOKEN_AMOUNT);
        tokenSale.setSendTokens(TOTAL_TOKEN_AMOUNT);
        vm.stopPrank();
        _;
    }

    function test_Revert_callingTwiceSetSendToken() public successfullyDeploy setSendToken {
        vm.startPrank(contractOwner);
        token.approve(address(tokenSale), TOTAL_TOKEN_AMOUNT);
        vm.expectRevert(bytes("TokenBalanceAlreadyOk"));
        tokenSale.setSendTokens(TOTAL_TOKEN_AMOUNT);
        vm.stopPrank();
    }

    //////////////////////////
    // MerkleRoot           //
    //////////////////////////

    function test_Revert_setAirdropMerkleRoot() public successfullyDeploy setSendToken {
        vm.prank(user);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        tokenSale.setAirdropMerkleRoot(bytes32(0x1a22147bba2925efd48ca48b860220617600b681013c3f91680b51b082bed39f));
    }

    function test_Revert_setSeedsaleMerkleRoot() public successfullyDeploy setSendToken {
        vm.prank(user);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        tokenSale.setSeedsaleMerkleRoot(bytes32(0x073d9c846828def16f872ba1c3c9da0d9eda7d47d652658b3203daf28cb1f398));
    }

    function test_Revert_setPresaleMerkleRoot() public successfullyDeploy setSendToken {
        vm.prank(user);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        tokenSale.setPresaleMerkleRoot(bytes32(0x724188b029894cbd0e18f48c6bdbae3bc4a10d47cdb48eb6eeb9899975a3fcb3));
    }

    function test_MerkleRoot() public successfullyDeploy setSendToken {
        vm.startPrank(contractOwner);
        tokenSale.setAirdropMerkleRoot(bytes32(0x1a22147bba2925efd48ca48b860220617600b681013c3f91680b51b082bed39f));
        tokenSale.setSeedsaleMerkleRoot(bytes32(0x073d9c846828def16f872ba1c3c9da0d9eda7d47d652658b3203daf28cb1f398));
        tokenSale.setPresaleMerkleRoot(bytes32(0x724188b029894cbd0e18f48c6bdbae3bc4a10d47cdb48eb6eeb9899975a3fcb3));
        vm.stopPrank();

        assertEq(
            tokenSale.airdropMerkleRoot(), bytes32(0x1a22147bba2925efd48ca48b860220617600b681013c3f91680b51b082bed39f)
        );
        assertEq(
            tokenSale.seedsaleMerkleRoot(), bytes32(0x073d9c846828def16f872ba1c3c9da0d9eda7d47d652658b3203daf28cb1f398)
        );
        assertEq(
            tokenSale.presaleMerkleRoot(), bytes32(0x724188b029894cbd0e18f48c6bdbae3bc4a10d47cdb48eb6eeb9899975a3fcb3)
        );
    }

    modifier setMerkleRoot() {
        vm.startPrank(contractOwner);
        tokenSale.setAirdropMerkleRoot(bytes32(0x1a22147bba2925efd48ca48b860220617600b681013c3f91680b51b082bed39f));
        tokenSale.setSeedsaleMerkleRoot(bytes32(0x073d9c846828def16f872ba1c3c9da0d9eda7d47d652658b3203daf28cb1f398));
        tokenSale.setPresaleMerkleRoot(bytes32(0x724188b029894cbd0e18f48c6bdbae3bc4a10d47cdb48eb6eeb9899975a3fcb3));
        vm.stopPrank();

        assertEq(
            tokenSale.airdropMerkleRoot(), bytes32(0x1a22147bba2925efd48ca48b860220617600b681013c3f91680b51b082bed39f)
        );
        assertEq(
            tokenSale.seedsaleMerkleRoot(), bytes32(0x073d9c846828def16f872ba1c3c9da0d9eda7d47d652658b3203daf28cb1f398)
        );
        assertEq(
            tokenSale.presaleMerkleRoot(), bytes32(0x724188b029894cbd0e18f48c6bdbae3bc4a10d47cdb48eb6eeb9899975a3fcb3)
        );
        _;
    }

    //////////////////////////
    // startAirdrop         //
    //////////////////////////
    function test_setStartAirdrop() public successfullyDeploy setSendToken setMerkleRoot {
        assertEq(tokenSale.isAirdropStarted(), false);
        vm.startPrank(contractOwner);
        tokenSale.setStartAirdrop(true);
        vm.stopPrank();

        assertEq(tokenSale.isAirdropStarted(), true);
    }

    //////////////////////////
    // startSeedSale        //
    //////////////////////////
    function test_setStartSeedsale() public successfullyDeploy setSendToken setMerkleRoot {
        assertEq(tokenSale.isSeedsaleStarted(), false);
        vm.startPrank(contractOwner);
        tokenSale.setStartAirdrop(true);
        vm.stopPrank();

        assertEq(tokenSale.isAirdropStarted(), true);
    }

    //////////////////////////
    // startPresale         //
    //////////////////////////
    function test_setStartPresale() public successfullyDeploy setSendToken setMerkleRoot {
        assertEq(tokenSale.isPresaleStarted(), false);
        vm.startPrank(contractOwner);
        tokenSale.setStartAirdrop(true);
        vm.stopPrank();

        assertEq(tokenSale.isAirdropStarted(), true);
    }

    //////////////////////////
    // startPublicsale      //
    //////////////////////////
    function test_setStartPublicsale() public successfullyDeploy setSendToken setMerkleRoot {
        assertEq(tokenSale.isPublicsaleStarted(), false);
        vm.startPrank(contractOwner);
        tokenSale.setStartAirdrop(true);
        vm.stopPrank();

        assertEq(tokenSale.isAirdropStarted(), true);
    }

    //////////////////////////
    // buyAirdrop           //
    //////////////////////////
    modifier buyAirdrop() {
        bytes32[] memory airdropAddress1Proof = new bytes32[](2);
        airdropAddress1Proof[0] = bytes32(0x1bec7c333d3d0c3eef8c6199a402856509c3f869d25408cc1cc2208d0371db0e);
        airdropAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        bytes32[] memory airdropAddress2Proof = new bytes32[](2);
        airdropAddress2Proof[0] = bytes32(0x94a6fc29a44456b36232638a7042431c9c91b910df1c52187179085fac1560e9);
        airdropAddress2Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        vm.prank(airdropAddress1);
        tokenSale.buyAirdrop(airdropAddress1Proof);
        assertEq(tokenSale.airdropBalances(airdropAddress1), tokenSale.AIRDROP_MAX_PER_WALLET());
        assertEq(tokenSale.airdropBuyed(), tokenSale.AIRDROP_MAX_PER_WALLET());

        vm.prank(airdropAddress2);
        tokenSale.buyAirdrop(airdropAddress2Proof);
        assertEq(tokenSale.airdropBalances(airdropAddress2), tokenSale.AIRDROP_MAX_PER_WALLET());
        assertEq(tokenSale.airdropBuyed(), tokenSale.AIRDROP_MAX_PER_WALLET() * 2);

        assertEq(tokenSale.AIRDROP_AMOUNT() - tokenSale.airdropBuyed(), 0);
        _;
    }

    function test_Revert_buyAirdrop_AirdropNotStarted() public successfullyDeploy setSendToken setMerkleRoot {
        bytes32[] memory airdropAddress1Proof = new bytes32[](2);
        airdropAddress1Proof[0] = bytes32(0x1bec7c333d3d0c3eef8c6199a402856509c3f869d25408cc1cc2208d0371db0e);
        airdropAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        assertEq(tokenSale.isAirdropStarted(), false);
        vm.prank(airdropAddress1);
        vm.expectRevert(bytes("AirdropNotStarted"));
        tokenSale.buyAirdrop(airdropAddress1Proof);
    }

    function test_Revert_buyAirdrop_InvalidMerkleProof() public successfullyDeploy setSendToken setMerkleRoot {
        bytes32[] memory airdropAddress1Proof = new bytes32[](2);
        vm.prank(airdropAddress1);
        vm.expectRevert(bytes("InvalidMerkleProof"));
        tokenSale.buyAirdrop(airdropAddress1Proof);
    }

    function test_Revert_buyAirdrop_AirdropAlreadyBuyed()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyAirdrop
    {
        bytes32[] memory airdropAddress1Proof = new bytes32[](2);
        airdropAddress1Proof[0] = bytes32(0x1bec7c333d3d0c3eef8c6199a402856509c3f869d25408cc1cc2208d0371db0e);
        airdropAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        vm.prank(airdropAddress1);
        vm.expectRevert(bytes("AirdropAlreadyBuyed"));
        tokenSale.buyAirdrop(airdropAddress1Proof);
    }

    function test_Revert_buyAirdrop_AirdropSoldOut() public successfullyDeploy setSendToken setMerkleRoot buyAirdrop {
        bytes32[] memory airdropAddress1Proof = new bytes32[](2);
        airdropAddress1Proof[0] = bytes32(0x1bec7c333d3d0c3eef8c6199a402856509c3f869d25408cc1cc2208d0371db0e);
        airdropAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        vm.warp(block.timestamp + tokenSale.AIRDROP_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 1);
        vm.startPrank(airdropAddress1);
        tokenSale.claimAirdrop(1);
        vm.expectRevert(bytes("AirdropSoldOut"));
        tokenSale.buyAirdrop(airdropAddress1Proof);
    }

    function test_buyAirdrop() public successfullyDeploy setSendToken setMerkleRoot buyAirdrop {}

    //////////////////////////
    // claimAirdrop         //
    //////////////////////////

    function test_claimAirdrop() public successfullyDeploy setSendToken setMerkleRoot buyAirdrop {
        assertEq(token.balanceOf(airdropAddress1), 0);
        vm.startPrank(airdropAddress1);
        for (uint256 i = 1; i <= tokenSale.AIRDROP_CLAIM_PERIOD(); i++) {
            vm.warp(block.timestamp + tokenSale.AIRDROP_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * i);
            tokenSale.claimAirdrop(i);
        }
        assertEq(token.balanceOf(airdropAddress1), tokenSale.AIRDROP_MAX_PER_WALLET() * 10 ** 18);
        vm.stopPrank();
    }

    function test_Revert_claimAirdrop_InvalidPeriod() public successfullyDeploy setSendToken setMerkleRoot buyAirdrop {
        assertEq(token.balanceOf(airdropAddress1), 0);
        vm.prank(airdropAddress1);
        vm.expectRevert(bytes("InvalidPeriod"));
        tokenSale.claimAirdrop(0);
    }

    function test_Revert_claimAirdrop_AirdropClaimNotStarted()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyAirdrop
    {
        assertEq(token.balanceOf(airdropAddress1), 0);
        vm.prank(airdropAddress1);
        vm.expectRevert(bytes("AirdropClaimNotStarted"));
        tokenSale.claimAirdrop(1);
    }

    function test_Revert_claimAirdrop_AirdropClaimPeriodNotStarted()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyAirdrop
    {
        vm.warp(block.timestamp + tokenSale.AIRDROP_CLAIM_START_TIME());
        assertEq(token.balanceOf(airdropAddress1), 0);
        vm.prank(airdropAddress1);
        vm.expectRevert(bytes("AirdropClaimPeriodNotStarted"));
        tokenSale.claimAirdrop(1);
    }

    function test_Revert_claimAirdrop_AirdropBalanceZero() public successfullyDeploy setSendToken setMerkleRoot {
        vm.warp(block.timestamp + tokenSale.AIRDROP_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 1);

        assertEq(token.balanceOf(airdropAddress1), 0);
        vm.prank(airdropAddress1);
        vm.expectRevert(bytes("AirdropBalanceZero"));
        tokenSale.claimAirdrop(1);
    }

    function test_Revert_claimAirdrop_BeforeClaimFirstPeriod()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyAirdrop
    {
        vm.warp(block.timestamp + tokenSale.AIRDROP_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 2);

        assertEq(token.balanceOf(airdropAddress1), 0);
        vm.prank(airdropAddress1);
        vm.expectRevert(bytes("BeforeClaimFirstPeriod"));
        tokenSale.claimAirdrop(2);
    }

    function test_Revert_claimAirdrop_AirdropAlreadyClaimed()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyAirdrop
    {
        vm.warp(block.timestamp + tokenSale.AIRDROP_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 1);

        assertEq(token.balanceOf(airdropAddress1), 0);
        vm.startPrank(airdropAddress1);
        tokenSale.claimAirdrop(1);

        vm.expectRevert(bytes("AirdropAlreadyClaimed"));
        tokenSale.claimAirdrop(1);
        vm.stopPrank();
    }

    //////////////////////////
    // buySeedsale          //
    //////////////////////////

    modifier buySeedSale() {
        bytes32[] memory seedSaleAddress1Proof = new bytes32[](2);
        seedSaleAddress1Proof[0] = bytes32(0x0ec177b07a450912768b0990e3f3942da56d7b24528a8ff010fef62bdc36ed2b);
        seedSaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        bytes32[] memory seedSaleAddress2Proof = new bytes32[](2);
        seedSaleAddress2Proof[0] = bytes32(0x1143df8268b94bd6292fdd7c9b8af39a79f764cfc03ae006844446bc91203927);
        seedSaleAddress2Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.SEEDSALE_PRICE();
        vm.prank(seedSaleAddress1);
        tokenSale.buySeedsale{value: etherValue}(seedSaleAddress1Proof, amount);
        assertEq(tokenSale.seedsaleBalances(seedSaleAddress1), amount);
        assertEq(tokenSale.seedsaleBuyed(), amount);

        // vm.prank(seedSaleAddress2);
        // tokenSale.buySeedsale{value: etherValue}(seedSaleAddress2Proof, amount);
        // assertEq(tokenSale.seedsaleBalances(seedSaleAddress2), amount);
        // assertEq(tokenSale.seedsaleBuyed(), amount * 2);

        // assertEq(tokenSale.SEEDSALE_AMOUNT() - tokenSale.seedsaleBuyed(), 0);
        _;
    }

    function test_buySeedSale() public successfullyDeploy setSendToken setMerkleRoot buySeedSale {}

    function test_Revert_buySeedsale_SeedsaleNotStarted() public successfullyDeploy setSendToken setMerkleRoot {
        bytes32[] memory seedSaleAddress1Proof = new bytes32[](2);
        seedSaleAddress1Proof[0] = bytes32(0x0ec177b07a450912768b0990e3f3942da56d7b24528a8ff010fef62bdc36ed2b);
        seedSaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        bytes32[] memory seedSaleAddress2Proof = new bytes32[](2);
        seedSaleAddress2Proof[0] = bytes32(0x1143df8268b94bd6292fdd7c9b8af39a79f764cfc03ae006844446bc91203927);
        seedSaleAddress2Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        vm.prank(seedSaleAddress1);
        vm.expectRevert(bytes("SeedsaleNotStarted"));
        tokenSale.buySeedsale(seedSaleAddress1Proof, amount);
    }

    function test_Revert_buySeedsale_InvalidMerkleProof() public successfullyDeploy setSendToken setMerkleRoot {
        bytes32[] memory seedSaleAddress1Proof = new bytes32[](2);

        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        vm.prank(seedSaleAddress1);
        vm.expectRevert(bytes("InvalidMerkleProof"));
        tokenSale.buySeedsale(seedSaleAddress1Proof, amount);
    }

    function test_Revert_buySeedsale_SeedsaleMaxPerWalletExceeded()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
    {
        bytes32[] memory seedSaleAddress1Proof = new bytes32[](2);
        seedSaleAddress1Proof[0] = bytes32(0x0ec177b07a450912768b0990e3f3942da56d7b24528a8ff010fef62bdc36ed2b);
        seedSaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        vm.prank(seedSaleAddress1);
        vm.expectRevert(bytes("SeedsaleMaxPerWalletExceeded"));
        tokenSale.buySeedsale(seedSaleAddress1Proof, amount + 1);
    }

    //@audit-issue buySeedsale is vulnerable, 1 person can buy MORE THAN SEEDSALE_MAX_PER_WALLET
    function test_Revert_buySeedsale_PoCSeedsaleSoldOut() public successfullyDeploy setSendToken setMerkleRoot {
        bytes32[] memory seedSaleAddress1Proof = new bytes32[](2);
        seedSaleAddress1Proof[0] = bytes32(0x0ec177b07a450912768b0990e3f3942da56d7b24528a8ff010fef62bdc36ed2b);
        seedSaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        uint256 amount = 6;
        uint256 etherValue = amount * tokenSale.SEEDSALE_PRICE();
        vm.prank(seedSaleAddress1);
        tokenSale.buySeedsale{value: etherValue}(seedSaleAddress1Proof, amount);
        assertEq(tokenSale.seedsaleBalances(seedSaleAddress1), amount);
        assertEq(tokenSale.seedsaleBuyed(), amount);

        // assertEq(tokenSale.seedsaleBalances(seedSaleAddress1), tokenSale.SEEDSALE_MAX_PER_WALLET());

        vm.startPrank(seedSaleAddress1);
        for (uint256 i = 1; i <= 4; i++) {
            vm.warp(block.timestamp + tokenSale.SEEDSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * i);
            tokenSale.claimSeedsale(i);
        }
        // vm.expectRevert(bytes("SeedsaleSoldOut"));
        uint256 etherValue2 = 13 * tokenSale.SEEDSALE_PRICE();
        tokenSale.buySeedsale{value: etherValue2}(seedSaleAddress1Proof, 13);
        emit log_named_uint("seedSaleAddress1", tokenSale.seedsaleBalances(seedSaleAddress1));
        tokenSale.claimSeedsale(5);
        emit log_named_decimal_uint("seedSaleAddress1", token.balanceOf(seedSaleAddress1), 18);
        vm.stopPrank();
    }

    function test_Revert_buySeedsale_SeedsaleSoldOut() public successfullyDeploy setSendToken setMerkleRoot {
        bytes32[] memory seedSaleAddress1Proof = new bytes32[](2);
        seedSaleAddress1Proof[0] = bytes32(0x0ec177b07a450912768b0990e3f3942da56d7b24528a8ff010fef62bdc36ed2b);
        seedSaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        bytes32[] memory seedSaleAddress2Proof = new bytes32[](2);
        seedSaleAddress2Proof[0] = bytes32(0x1143df8268b94bd6292fdd7c9b8af39a79f764cfc03ae006844446bc91203927);
        seedSaleAddress2Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.SEEDSALE_PRICE();
        vm.prank(seedSaleAddress1);
        tokenSale.buySeedsale{value: etherValue}(seedSaleAddress1Proof, amount);
        assertEq(tokenSale.seedsaleBalances(seedSaleAddress1), amount);
        assertEq(tokenSale.seedsaleBuyed(), amount);

        vm.prank(seedSaleAddress2);
        vm.expectRevert(bytes("SeedsaleSoldOut"));
        tokenSale.buySeedsale{value: etherValue}(seedSaleAddress2Proof, amount);
        // assertEq(tokenSale.seedsaleBalances(seedSaleAddress2), amount);
        // assertEq(tokenSale.seedsaleBuyed(), amount * 2);
    }

    function test_Revert_buySeedsale_InvalidBalance() public successfullyDeploy setSendToken setMerkleRoot {
        bytes32[] memory seedSaleAddress1Proof = new bytes32[](2);
        seedSaleAddress1Proof[0] = bytes32(0x0ec177b07a450912768b0990e3f3942da56d7b24528a8ff010fef62bdc36ed2b);
        seedSaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        vm.prank(seedSaleAddress1);
        vm.expectRevert(bytes("InvalidBalance"));
        tokenSale.buySeedsale(seedSaleAddress1Proof, amount);
    }

    //////////////////////////
    // claimSeedsale        //
    //////////////////////////

    function test_claimSeedsale() public successfullyDeploy setSendToken setMerkleRoot {}

    function test_Revert_claimSeedsale_InvalidPeriod()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buySeedSale
    {
        vm.expectRevert(bytes("InvalidPeriod"));
        tokenSale.claimSeedsale(0);
    }

    function test_Revert_claimSeedsale_SeedsaleClaimNotStarted()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buySeedSale
    {
        vm.startPrank(seedSaleAddress1);
        vm.expectRevert(bytes("SeedsaleClaimNotStarted"));
        tokenSale.claimSeedsale(1);
        vm.stopPrank();
    }

    function test_Revert_claimSeedsale_SeedsaleClaimPeriodNotStarted()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buySeedSale
    {
        vm.warp(block.timestamp + tokenSale.SEEDSALE_CLAIM_START_TIME());
        vm.startPrank(seedSaleAddress1);
        vm.expectRevert(bytes("SeedsaleClaimPeriodNotStarted"));
        tokenSale.claimSeedsale(1);
        vm.stopPrank();
    }

    function test_Revert_claimSeedsale_SeedsaleBalanceZero() public successfullyDeploy setSendToken setMerkleRoot {
        vm.warp(block.timestamp + tokenSale.SEEDSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 1);
        vm.startPrank(seedSaleAddress1);
        vm.expectRevert(bytes("SeedsaleBalanceZero"));
        tokenSale.claimSeedsale(1);
        vm.stopPrank();
    }

    function test_Revert_claimSeedsale_BeforeClaimFirstPeriod()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buySeedSale
    {
        vm.warp(block.timestamp + tokenSale.SEEDSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 2);
        vm.startPrank(seedSaleAddress1);
        vm.expectRevert(bytes("BeforeClaimFirstPeriod"));
        tokenSale.claimSeedsale(2);
        vm.stopPrank();
    }

    function test_Revert_claimSeedsale_SeedsaleAlreadyClaimed()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buySeedSale
    {
        vm.warp(block.timestamp + tokenSale.SEEDSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 1);
        vm.startPrank(seedSaleAddress1);
        tokenSale.claimSeedsale(1);
        vm.expectRevert(bytes("SeedsaleAlreadyClaimed"));
        tokenSale.claimSeedsale(1);
        vm.stopPrank();
    }

    //////////////////////////
    // buyPresale           //
    //////////////////////////

    modifier buyPresale() {
        bytes32[] memory presaleAddress1Proof = new bytes32[](2);
        presaleAddress1Proof[0] = bytes32(0x487a0fa9fe1271bede1abe958efd4a3e46c23bd75ee1766be76ac527effefdb2);
        presaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        bytes32[] memory presaleAddress2Proof = new bytes32[](2);
        presaleAddress2Proof[0] = bytes32(0x214ce8fb7807e8a6d3aae20a0447e848c2b2676ee5ee6c7bd6badaed66a2f817);
        presaleAddress2Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PRESALE_PRICE();
        vm.prank(presaleAddress1);
        tokenSale.buyPresale{value: etherValue}(presaleAddress1Proof, amount);
        assertEq(tokenSale.presaleBalances(presaleAddress1), amount);
        assertEq(tokenSale.presaleBuyed(), amount);

        // vm.prank(presaleAddress2);
        // tokenSale.buyPresale{value: etherValue}(presaleAddress2Proof, amount);
        // assertEq(tokenSale.presaleBalances(presaleAddress2), amount);
        // assertEq(tokenSale.presaleBuyed(), amount * 2);

        // assertEq(tokenSale.PRESALE_AMOUNT() - tokenSale.presaleBuyed(), 0);
        _;
    }

    function test_buyPresale() public successfullyDeploy setSendToken setMerkleRoot buyPresale {}

    function test_Revert_buyPresale_PresaleNotStarted() public successfullyDeploy setSendToken setMerkleRoot {
        assertEq(tokenSale.isPresaleStarted(), false);
        // vm.startPrank(contractOwner);
        // tokenSale.setStartPresale(true);
        // vm.stopPrank();

        bytes32[] memory presaleAddress1Proof = new bytes32[](2);
        presaleAddress1Proof[0] = bytes32(0x487a0fa9fe1271bede1abe958efd4a3e46c23bd75ee1766be76ac527effefdb2);
        presaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        // bytes32[] memory presaleAddress2Proof = new bytes32[](2);
        // presaleAddress2Proof[0] = bytes32(0x214ce8fb7807e8a6d3aae20a0447e848c2b2676ee5ee6c7bd6badaed66a2f817);
        // presaleAddress2Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PRESALE_PRICE();
        vm.prank(presaleAddress1);
        vm.expectRevert(bytes("PresaleNotStarted"));
        tokenSale.buyPresale{value: etherValue}(presaleAddress1Proof, amount);
    }

    function test_Revert_buyPresale_InvalidMerkleProof() public successfullyDeploy setSendToken setMerkleRoot {
        // assertEq(tokenSale.isPresaleStarted(), false);
        // vm.startPrank(contractOwner);
        // tokenSale.setStartPresale(true);
        // vm.stopPrank();

        bytes32[] memory presaleAddress1Proof = new bytes32[](2);
        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PRESALE_PRICE();
        vm.prank(presaleAddress1);
        vm.expectRevert(bytes("InvalidMerkleProof"));
        tokenSale.buyPresale{value: etherValue}(presaleAddress1Proof, amount);
    }

    function test_Revert_buyPresale_PresaleMaxPerWalletExceeded()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
    {
        // assertEq(tokenSale.isPresaleStarted(), false);
        // vm.startPrank(contractOwner);
        // tokenSale.setStartPresale(true);
        // vm.stopPrank();

        bytes32[] memory presaleAddress1Proof = new bytes32[](2);
        presaleAddress1Proof[0] = bytes32(0x487a0fa9fe1271bede1abe958efd4a3e46c23bd75ee1766be76ac527effefdb2);
        presaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PRESALE_PRICE();
        vm.prank(presaleAddress1);
        vm.expectRevert(bytes("PresaleMaxPerWalletExceeded"));
        tokenSale.buyPresale{value: etherValue}(presaleAddress1Proof, amount + 1);
    }

    function test_Revert_buyPresale_PresaleSoldOut() public successfullyDeploy setSendToken setMerkleRoot {
        // assertEq(tokenSale.isPresaleStarted(), false);
        // vm.startPrank(contractOwner);
        // tokenSale.setStartPresale(true);
        // vm.stopPrank();

        bytes32[] memory presaleAddress1Proof = new bytes32[](2);
        presaleAddress1Proof[0] = bytes32(0x487a0fa9fe1271bede1abe958efd4a3e46c23bd75ee1766be76ac527effefdb2);
        presaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        bytes32[] memory presaleAddress2Proof = new bytes32[](2);
        presaleAddress2Proof[0] = bytes32(0x214ce8fb7807e8a6d3aae20a0447e848c2b2676ee5ee6c7bd6badaed66a2f817);
        presaleAddress2Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PRESALE_PRICE();
        vm.prank(presaleAddress1);
        tokenSale.buyPresale{value: etherValue}(presaleAddress1Proof, amount);

        vm.startPrank(presaleAddress2);
        vm.expectRevert(bytes("PresaleSoldOut"));
        tokenSale.buyPresale{value: etherValue}(presaleAddress2Proof, amount);
    }

    //@audit-issue buyPresale is vulnerable, 1 person can buy MORE THAN PRESALE_MAX_PER_WALLET
    function test_Revert_buyPresale_PoCPresaleSoldOut() public successfullyDeploy setSendToken setMerkleRoot {
        bytes32[] memory presaleAddress1Proof = new bytes32[](2);
        presaleAddress1Proof[0] = bytes32(0x487a0fa9fe1271bede1abe958efd4a3e46c23bd75ee1766be76ac527effefdb2);
        presaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);
        uint256 amount = 6;
        uint256 etherValue = amount * tokenSale.PRESALE_PRICE();
        vm.prank(presaleAddress1);
        tokenSale.buyPresale{value: etherValue}(presaleAddress1Proof, amount);
        assertEq(tokenSale.presaleBalances(presaleAddress1), amount);
        assertEq(tokenSale.presaleBuyed(), amount);

        vm.startPrank(presaleAddress1);
        for (uint256 i = 1; i <= 4; i++) {
            vm.warp(block.timestamp + tokenSale.PRESALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * i);
            tokenSale.claimPresale(i);
        }
        // vm.expectRevert(bytes("PresaleSoldOut"));
        uint256 etherValue2 = 13 * tokenSale.PRESALE_PRICE();
        tokenSale.buyPresale{value: etherValue2}(presaleAddress1Proof, 13);
        emit log_named_uint("presaleAddress1", tokenSale.presaleBalances(presaleAddress1));
        tokenSale.claimPresale(5);
        emit log_named_decimal_uint("presaleAddress1", token.balanceOf(presaleAddress1), 18);
        vm.stopPrank();
    }

    function test_Revert_buyPresale_InvalidBalance() public successfullyDeploy setSendToken setMerkleRoot {
        // assertEq(tokenSale.isPresaleStarted(), false);
        // vm.startPrank(contractOwner);
        // tokenSale.setStartPresale(true);
        // vm.stopPrank();

        bytes32[] memory presaleAddress1Proof = new bytes32[](2);
        presaleAddress1Proof[0] = bytes32(0x487a0fa9fe1271bede1abe958efd4a3e46c23bd75ee1766be76ac527effefdb2);
        presaleAddress1Proof[1] = bytes32(0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2);

        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PRESALE_PRICE();
        vm.prank(presaleAddress1);
        vm.expectRevert(bytes("InvalidBalance"));
        tokenSale.buyPresale{value: etherValue - 1}(presaleAddress1Proof, amount);
    }

    //////////////////////////
    // claimPresale         //
    //////////////////////////

    function test_Revert_claimPresale_InvalidPeriod() public successfullyDeploy setSendToken setMerkleRoot buyPresale {
        vm.prank(presaleAddress1);
        vm.expectRevert(bytes("InvalidPeriod"));
        tokenSale.claimPresale(0);
    }

    function test_Revert_claimPresale_PresaleClaimNotStarted()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyPresale
    {
        vm.prank(presaleAddress1);
        vm.expectRevert(bytes("PresaleClaimNotStarted"));
        tokenSale.claimPresale(1);
    }

    function test_Revert_claimPresale_PresaleClaimPeriodNotStarted()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyPresale
    {
        vm.warp(block.timestamp + tokenSale.PRESALE_CLAIM_START_TIME());
        vm.prank(presaleAddress1);
        vm.expectRevert(bytes("PresaleClaimPeriodNotStarted"));
        tokenSale.claimPresale(1);
    }

    function test_Revert_claimPresale_PresaleBalanceZero() public successfullyDeploy setSendToken setMerkleRoot {
        vm.warp(block.timestamp + tokenSale.PRESALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 1);
        vm.prank(presaleAddress1);
        vm.expectRevert(bytes("PresaleBalanceZero"));
        tokenSale.claimPresale(1);
    }

    function test_Revert_claimPresale_BeforeClaimFirstPeriod()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyPresale
    {
        vm.warp(block.timestamp + tokenSale.PRESALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 2);
        vm.prank(presaleAddress1);
        vm.expectRevert(bytes("BeforeClaimFirstPeriod"));
        tokenSale.claimPresale(2);
    }

    function test_Revert_claimPresale_PresaleAlreadyClaimed()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyPresale
    {
        vm.warp(block.timestamp + tokenSale.PRESALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 1);
        vm.startPrank(presaleAddress1);
        tokenSale.claimPresale(1);
        vm.expectRevert(bytes("PresaleAlreadyClaimed"));
        tokenSale.claimPresale(1);
        vm.stopPrank();
    }

    //////////////////////////
    // setTransferToPublic  //
    //////////////////////////

    function test_Revert_setTransferToPublic_Owner()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyAirdrop
        buySeedSale
        buyPresale
    {
        // vm.prank(contractOwner);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        tokenSale.setTransferToPublic();
    }

    function test_Revert_setTransferToPublic_SalesCountinue()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyAirdrop
        buySeedSale
        buyPresale
    {
        vm.startPrank(contractOwner);
        tokenSale.setStartPublicsale(true);

        vm.expectRevert(bytes("SalesCountinue"));
        tokenSale.setTransferToPublic();
        vm.stopPrank();
    }

    modifier setTransferToPublic() {
        vm.startPrank(contractOwner);
        tokenSale.setTransferToPublic();
        vm.stopPrank();
        _;
    }

    //////////////////////////
    // buyPublicsale        //
    //////////////////////////

    modifier buyPublicSale() {
        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PUBLICSALE_PRICE();
        vm.prank(publicSaleAddress1);
        tokenSale.buyPublicsale{value: etherValue}(amount);
        assertEq(tokenSale.publicsaleBalances(publicSaleAddress1), amount);
        assertEq(tokenSale.publicsaleBuyed(), amount);

        // vm.prank(publicSaleAddress2);
        // tokenSale.buyPublicsale{value: etherValue}(amount);
        // assertEq(tokenSale.publicsaleBalances(publicSaleAddress2), amount);
        // assertEq(tokenSale.publicsaleBuyed(), amount * 2);

        // assertEq(tokenSale.PUBLICSALE_AMOUNT() - tokenSale.publicsaleBuyed(), 0);
        _;
    }

    function test_buyPublicsale() public successfullyDeploy setSendToken setMerkleRoot buyPublicSale {}

    function test_Revert_buyPublicsale_PublicsaleNotStarted() public successfullyDeploy setSendToken setMerkleRoot {
        assertEq(tokenSale.isPublicsaleStarted(), false);

        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PUBLICSALE_PRICE();

        vm.prank(publicSaleAddress1);
        vm.expectRevert(bytes("PublicsaleNotStarted"));
        tokenSale.buyPublicsale{value: etherValue}(amount);
    }

    function test_Revert_buyPublicsale_PublicsaleMaxPerWalletExceeded() public successfullyDeploy setSendToken {
        assertEq(tokenSale.isPublicsaleStarted(), false);

        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PUBLICSALE_PRICE();

        // vm.startPrank(contractOwner);
        // tokenSale.setStartPublicsale(true);
        // vm.stopPrank();

        vm.prank(publicSaleAddress1);
        vm.expectRevert(bytes("PublicsaleMaxPerWalletExceeded"));
        tokenSale.buyPublicsale{value: etherValue}(amount + 1);
    }

    function test_Revert_buyPublicsale_PublicsaleSoldOut() public successfullyDeploy setSendToken {
        assertEq(tokenSale.isPublicsaleStarted(), false);

        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PUBLICSALE_PRICE();

        // vm.startPrank(contractOwner);
        // tokenSale.setStartPublicsale(true);
        // vm.stopPrank();

        vm.prank(publicSaleAddress1);
        tokenSale.buyPublicsale{value: etherValue}(amount);

        vm.prank(publicSaleAddress2);
        vm.expectRevert(bytes("PublicsaleSoldOut"));
        tokenSale.buyPublicsale{value: etherValue}(amount);
    }

    function test_Revert_buyPublicsale_InvalidBalance() public successfullyDeploy setSendToken {
        assertEq(tokenSale.isPublicsaleStarted(), false);

        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET();
        uint256 etherValue = amount * tokenSale.PUBLICSALE_PRICE();

        // vm.startPrank(contractOwner);
        // tokenSale.setStartPublicsale(true);
        // vm.stopPrank();

        vm.prank(publicSaleAddress1);
        vm.expectRevert(bytes("InvalidBalance"));
        tokenSale.buyPublicsale{value: etherValue - 1}(amount);
    }

    //////////////////////////
    // claimPublicsale      //
    //////////////////////////

    function test_Revert_claimPublicsale_InvalidPeriod()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyPublicSale
    {
        vm.prank(publicSaleAddress1);
        vm.expectRevert(bytes("InvalidPeriod"));
        tokenSale.claimPublicsale(0);
    }

    function test_Revert_claimPublicsale_PublicsaleClaimNotStarted()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyPublicSale
    {
        vm.prank(publicSaleAddress1);
        vm.expectRevert(bytes("PublicsaleClaimNotStarted"));
        tokenSale.claimPublicsale(1);
    }

    function test_Revert_claimPublicsale_PublicsaleClaimPeriodNotStarted()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyPublicSale
    {
        vm.warp(block.timestamp + tokenSale.PUBLICSALE_CLAIM_START_TIME());
        vm.prank(publicSaleAddress1);
        vm.expectRevert(bytes("PublicsaleClaimPeriodNotStarted"));
        tokenSale.claimPublicsale(1);
    }

    function test_Revert_claimPublicsale_PublicsaleBalanceZero() public successfullyDeploy setSendToken setMerkleRoot {
        vm.warp(block.timestamp + tokenSale.PUBLICSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 1);
        vm.prank(publicSaleAddress1);
        vm.expectRevert(bytes("PublicsaleBalanceZero"));
        tokenSale.claimPublicsale(1);
    }

    function test_Revert_claimPublicsale_BeforeClaimFirstPeriod()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyPublicSale
    {
        vm.warp(block.timestamp + tokenSale.PUBLICSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 2);
        vm.prank(publicSaleAddress1);
        vm.expectRevert(bytes("BeforeClaimFirstPeriod"));
        tokenSale.claimPublicsale(2);
    }

    function test_Revert_claimPublicsale_PublicsaleAlreadyClaimed()
        public
        successfullyDeploy
        setSendToken
        setMerkleRoot
        buyPublicSale
    {
        vm.warp(block.timestamp + tokenSale.PUBLICSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * 1);
        vm.startPrank(publicSaleAddress1);
        tokenSale.claimPublicsale(1);
        vm.expectRevert(bytes("PublicsaleAlreadyClaimed"));
        tokenSale.claimPublicsale(1);
        vm.stopPrank();
    }

    //////////////////////////
    // precision errors    //
    //////////////////////////

    function test_first4period_userGets0tokens() public successfullyDeploy setSendToken setMerkleRoot {
        uint256 amount = 4;
        uint256 etherValue = amount * tokenSale.PUBLICSALE_PRICE();
        vm.startPrank(publicSaleAddress1);
        tokenSale.buyPublicsale{value: etherValue}(amount);
        assertEq(tokenSale.publicsaleBalances(publicSaleAddress1), amount);
        assertEq(tokenSale.publicsaleBuyed(), amount);

        for (uint256 i = 1; i <= 4; i++) {
            vm.warp(block.timestamp + tokenSale.PUBLICSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME() * i);
            tokenSale.claimPublicsale(i);
            emit log_named_decimal_uint("publicSaleAddress1:", token.balanceOf(publicSaleAddress1), 18);
        }
        tokenSale.claimPublicsale(5);
        emit log_named_decimal_uint("publicSaleAddress1:", token.balanceOf(publicSaleAddress1), 18);

        vm.stopPrank();
    }
}
