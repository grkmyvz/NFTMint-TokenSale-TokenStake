// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//////////////////////////////////////////
// Imports
//////////////////////////////////////////
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

/**
 * @title TokenSale
 * @dev A contract for managing a token sale with different phases (airdrop, presale, seedsale, publicsale).
 * @author --. --- .-. -.- . -- / -.-- .- ...- ..- --..
 */
contract TokenSale is Ownable, ReentrancyGuard {
    //////////////////////////////////////////
    // Errors
    //////////////////////////////////////////
    error AirdropNotStarted();
    error SeedsaleNotStarted();
    error PresaleNotStarted();
    error PublicsaleNotStarted();
    error InvalidAmount();
    error InvalidBalance();
    error InvalidTokenAddress();
    error FirstSendTokens();
    error TokenBalanceAlreadyOk();
    error SalesCountinue();
    error WithdrawalFailed();
    error InvalidMerkleProof();
    error AirdropAlreadyBuyed();
    error AirdropSoldOut();
    error SeedsaleMaxPerWalletExceeded();
    error SeedsaleSoldOut();
    error PresaleMaxPerWalletExceeded();
    error PresaleSoldOut();
    error PublicsaleMaxPerWalletExceeded();
    error PublicsaleSoldOut();
    error InvalidPeriod();
    error ZeroBalance();
    error BeforeClaimFirstPeriod();
    error AirdropClaimPeriodNotStarted();
    error AirdropAlreadyClaimed();
    error SeedsaleClaimPeriodNotStarted();
    error SeedsaleAlreadyClaimed();
    error PresaleClaimPeriodNotStarted();
    error PresaleAlreadyClaimed();
    error PublicsaleClaimPeriodNotStarted();
    error PublicsaleAlreadyClaimed();

    //////////////////////////////////////////
    // Interfaces
    //////////////////////////////////////////
    // SafeERC20 Interface
    using SafeERC20 for IERC20;
    IERC20 public token;

    //////////////////////////////////////////
    // Variables
    //////////////////////////////////////////
    // THIS VARIBALES CAN BE CHANGED //
    uint256 public AIRDROP_AMOUNT = 10; // Maximum amount of tokens for the airdrop.
    uint256 public AIRDROP_MAX_PER_WALLET = 6; // Maximum amount of tokens per wallet for the airdrop.
    uint256 public AIRDROP_CLAIM_START_TIME = 100; // Start time for the airdrop claim.
    uint256 public AIRDROP_CLAIM_PERIOD = 5; // Claim period for the airdrop.
    uint256 public SEEDSALE_AMOUNT = 20; // Maximum amount of tokens for the seedsale.
    uint256 public SEEDSALE_MAX_PER_WALLET = 11; // Maximum amount of tokens per wallet for the seedsale.
    uint256 public SEEDSALE_PRICE = 0.1 * 10 ** 18; // Price of the seedsale.
    uint256 public SEEDSALE_CLAIM_START_TIME = 200; // Start time for the seedsale claim.
    uint256 public SEEDSALE_CLAIM_PERIOD = 5; // Claim period for the seedsale.
    uint256 public PRESALE_AMOUNT = 30; // Maximum amount of tokens for the presale.
    uint256 public PRESALE_MAX_PER_WALLET = 16; // Maximum amount of tokens per wallet for the presale.
    uint256 public PRESALE_PRICE = 0.2 * 10 ** 18; // Price of the presale.
    uint256 public PRESALE_CLAIM_START_TIME = 300; // Start time for the presale claim.
    uint256 public PRESALE_CLAIM_PERIOD = 5; // Claim period for the presale.
    uint256 public PUBLICSALE_AMOUNT = 40; // Maximum amount of tokens for the publicsale.
    uint256 public PUBLICSALE_MAX_PER_WALLET = 21; // Maximum amount of tokens per wallet for the publicsale.
    uint256 public PUBLICSALE_PRICE = 0.5 * 10 ** 18; // Price of the publicsale.
    uint256 public PUBLICSALE_CLAIM_START_TIME = 400; // Start time for the publicsale claim.
    uint256 public PUBLICSALE_CLAIM_PERIOD = 5; // Claim period for the publicsale.
    uint256 public PERIOD_TIME = 10; // Period time for the claims. Example: 2592000 (30 days).
    // THIS VARIBALES CAN BE CHANGED //

    uint256 public airdropBuyed;
    uint256 public seedsaleBuyed;
    uint256 public presaleBuyed;
    uint256 public publicsaleBuyed;

    mapping(address => uint256) public airdropBalances;
    mapping(address => uint256) public seedsaleBalances;
    mapping(address => uint256) public presaleBalances;
    mapping(address => uint256) public publicsaleBalances;

    mapping(address => mapping(uint256 => uint256))
        public airdropClaimedPerPeriod;
    mapping(address => mapping(uint256 => uint256))
        public seedsaleClaimedPerPeriod;
    mapping(address => mapping(uint256 => uint256))
        public presaleClaimedPerPeriod;
    mapping(address => mapping(uint256 => uint256))
        public publicsaleClaimedPerPeriod;

    bool public isTokenBalanceOk;
    bool public airdropStatus;
    bool public seedsaleStatus;
    bool public presaleStatus;
    bool public publicsaleStatus;

    bytes32 public airdropMerkleRoot;
    bytes32 public seedsaleMerkleRoot;
    bytes32 public presaleMerkleRoot;

    //////////////////////////////////////////
    // Events
    //////////////////////////////////////////
    event SendTokens(uint256 _amount);
    event ChangedAirdropStatus(uint256 _timestamp);
    event ChangedSeedsaleStatus(uint256 _timestamp);
    event ChangedPresaleStatus(uint256 _timestamp);
    event ChangedPublicsaleStatus(uint256 _timestamp);
    event TransferToPublic(uint256 _amount);
    event AirdropBuyed(address indexed _buyer, uint256 _amount);
    event SeedsaleBuyed(address indexed _buyer, uint256 _amount);
    event PresaleBuyed(address indexed _buyer, uint256 _amount);
    event PublicsaleBuyed(address indexed _buyer, uint256 _amount);
    event AirdropClaimed(address indexed _buyer, uint256 _amount);
    event SeedsaleClaimed(address indexed _buyer, uint256 _amount);
    event PresaleClaimed(address indexed _buyer, uint256 _amount);
    event PublicsaleClaimed(address indexed _buyer, uint256 _amount);
    event OwnerWithdrawCoin(uint256 _amount, bytes _data);
    event OwnerWithdrawToken(uint256 _amount);

    //////////////////////////////////////////
    // Modifiers
    //////////////////////////////////////////
    modifier isAirdropStarted() {
        if (!airdropStatus) {
            revert AirdropNotStarted();
        }
        _;
    }

    modifier isSeedsaleStarted() {
        if (!seedsaleStatus) {
            revert SeedsaleNotStarted();
        }
        _;
    }

    modifier isPresaleStarted() {
        if (!presaleStatus) {
            revert PresaleNotStarted();
        }
        _;
    }

    modifier isPublicsaleStarted() {
        if (!publicsaleStatus) {
            revert PublicsaleNotStarted();
        }
        _;
    }

    modifier checkZeroAmount(uint256 _amount) {
        if (_amount == 0) {
            revert InvalidAmount();
        }
        _;
    }

    //////////////////////////////////////////
    // Functions
    //////////////////////////////////////////
    constructor(address _tokenAddress) {
        if (_tokenAddress == address(0)) {
            revert InvalidTokenAddress();
        }

        token = IERC20(_tokenAddress);
    }

    // < Private Functions >
    /**
     * @notice Verify airdrop merkle proof of the address.
     * @param _merkleProof Merkle proof for the user's address.
     * @return Whether the provided Merkle proof is valid for the airdrop.
     */
    function _verifyAirdrop(
        bytes32[] calldata _merkleProof
    ) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, airdropMerkleRoot, leaf);
    }

    /**
     * @notice Verify seedsale merkle proof of the address.
     * @param _merkleProof Merkle proof for the user's address.
     * @return Whether the provided Merkle proof is valid for the seedsale.
     */
    function _verifySeedsale(
        bytes32[] calldata _merkleProof
    ) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, seedsaleMerkleRoot, leaf);
    }

    /**
     * @notice Verify presale merkle proof of the address.
     * @param _merkleProof Merkle proof for the user's address.
     * @return Whether the provided Merkle proof is valid for the presale.
     */

    function _verifyPresale(
        bytes32[] calldata _merkleProof
    ) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, presaleMerkleRoot, leaf);
    }

    /**
     * @notice Verify airdrop amount of the address.
     * @return Whether the provided amount is valid for the airdrop.
     */
    function _verifyAirdropAmount() private view returns (bool) {
        uint256 checkAmount;
        for (uint256 i = 1; i <= AIRDROP_CLAIM_PERIOD; i++) {
            checkAmount += airdropClaimedPerPeriod[msg.sender][i];
        }
        checkAmount += airdropBalances[msg.sender];

        if (checkAmount >= AIRDROP_MAX_PER_WALLET) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Verify seedsale amount of the address.
     * @return Whether the provided amount is valid for the seedsale.
     */
    function _verifySeedsaleAmount(
        uint256 _amount
    ) private view returns (bool) {
        uint256 checkAmount;
        for (uint256 i = 1; i <= SEEDSALE_CLAIM_PERIOD; i++) {
            checkAmount += seedsaleClaimedPerPeriod[msg.sender][i];
        }
        checkAmount += seedsaleBalances[msg.sender];
        checkAmount += _amount;

        if (checkAmount > SEEDSALE_MAX_PER_WALLET) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Verify presale amount of the address.
     * @return Whether the provided amount is valid for the presale.
     */
    function _verifyPresaleAmount(uint256 _amount) private view returns (bool) {
        uint256 checkAmount;
        for (uint256 i = 1; i <= PRESALE_CLAIM_PERIOD; i++) {
            checkAmount += presaleClaimedPerPeriod[msg.sender][i];
        }
        checkAmount += presaleBalances[msg.sender];
        checkAmount += _amount;

        if (checkAmount > PRESALE_MAX_PER_WALLET) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Verify publicsale amount of the address.
     * @return Whether the provided amount is valid for the publicsale.
     */
    function _verifyPublicsaleAmount(
        uint256 _amount
    ) private view returns (bool) {
        uint256 checkAmount;
        for (uint256 i = 1; i <= PUBLICSALE_CLAIM_PERIOD; i++) {
            checkAmount += publicsaleClaimedPerPeriod[msg.sender][i];
        }
        checkAmount += publicsaleBalances[msg.sender];
        checkAmount += _amount;

        if (checkAmount > PUBLICSALE_MAX_PER_WALLET) {
            return true;
        } else {
            return false;
        }
    }

    // </ Private Functions >
    // < Only Owner Functions >
    /**
     * @notice Sends tokens to the contract.
     * @dev Only the contract owner can use this function to send tokens for the sale and marks the token balance as ready.
     * @param _amount The total amount of tokens to be sent for the sale.
     * emit SendTokens is an event that is emitted when the tokens are sent to the contract.
     */
    function setSendTokens(uint256 _amount) external onlyOwner {
        if (isTokenBalanceOk) {
            revert TokenBalanceAlreadyOk();
        }
        if (
            (AIRDROP_AMOUNT +
                SEEDSALE_AMOUNT +
                PRESALE_AMOUNT +
                PUBLICSALE_AMOUNT) *
                10 ** 18 !=
            _amount
        ) {
            revert InvalidAmount();
        }

        isTokenBalanceOk = true;

        token.safeTransferFrom(msg.sender, address(this), _amount);

        emit SendTokens(_amount);
    }

    /**
     * @notice Change airdrop merkle root.
     * @dev Only the contract owner can change the merkle root for the airdrop.
     * @param _merkleRoot New merkle root for the airdrop.
     */
    function setAirdropMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        if (_merkleRoot == bytes32(0)) {
            revert InvalidMerkleProof();
        }

        airdropMerkleRoot = _merkleRoot;
    }

    /**
     * @notice Change seedsale merkle root.
     * @dev Only the contract owner can change the merkle root hash for the seedsale.
     * @param _merkleRoot New merkle root for the seedsale.
     */
    function setSeedsaleMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        if (_merkleRoot == bytes32(0)) {
            revert InvalidMerkleProof();
        }

        seedsaleMerkleRoot = _merkleRoot;
    }

    /**
     * @notice Change presale merkle root.
     * @dev Only the contract owner can change the merkle root for the presale.
     * @param _merkleRoot New merkle root for the presale.
     */
    function setPresaleMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        if (_merkleRoot == bytes32(0)) {
            revert InvalidMerkleProof();
        }

        presaleMerkleRoot = _merkleRoot;
    }

    /**
     * @notice Start or stop the Airdrop sale phase.
     * @dev Only the contract owner can start the Airdrop sale.
     * @param _status The status indicating whether to start or stop the Airdrop phase.
     * emit ChangedAirdropStatus is an event that is emitted when the Airdrop status is changed.
     */
    function setAirdropStatus(bool _status) external onlyOwner {
        if (!isTokenBalanceOk) {
            revert FirstSendTokens();
        }

        airdropStatus = _status;

        emit ChangedAirdropStatus(block.timestamp);
    }

    /**
     * @notice Start or stop the Seedsale phase.
     * @dev Only the contract owner can start the Seedsale phase.
     * @param _status The status indicating whether to start or stop the Seedsale phase.
     * emit ChangedSeedsaleStatus is an event that is emitted when the Seedsale status is changed.
     */
    function setSeedsaleStatus(bool _status) external onlyOwner {
        if (!isTokenBalanceOk) {
            revert FirstSendTokens();
        }

        seedsaleStatus = _status;

        emit ChangedSeedsaleStatus(block.timestamp);
    }

    /**
     * @notice Start or stop the Presale phase.
     * @dev Only the contract owner can start the Presale phase.
     * @param _status The status indicating whether to start or stop the Presale phase.
     * emit ChangedPresaleStatus is an event that is emitted when the Presale status is changed.
     */
    function setPresaleStatus(bool _status) external onlyOwner {
        if (!isTokenBalanceOk) {
            revert FirstSendTokens();
        }

        presaleStatus = _status;

        emit ChangedPresaleStatus(block.timestamp);
    }

    /**
     * @notice Start or stop the Publicsale phase.
     * @dev Only the contract owner can start the Publicsale phase and this can only be done if no other sales phases are active.
     * If the Publicsale phase is started, the remaining tokens from the other sales phases are transferred to the Publicsale phase.
     * @param _status The status indicating whether to start or stop the Publicsale phase.
     * emit ChangedPublicsaleStatus is an event that is emitted when the Publicsale status is changed.
     */
    function setPublicsaleStatus(bool _status) external onlyOwner {
        if (!isTokenBalanceOk) {
            revert FirstSendTokens();
        }
        if (_status) {
            setTransferToPublic();
        }
        publicsaleStatus = _status;

        emit ChangedPublicsaleStatus(block.timestamp);
    }

    /**
     * @notice Transfer remaining tokens to the Publicsale phase.
     * @dev Only the contract owner can transfer tokens to the Publicsale phase, and this can only be done if no other sales phases are active.
     * emit TransferToPublic is an event that is emitted when the remaining tokens are transferred to the Publicsale phase.
     */
    function setTransferToPublic() internal onlyOwner {
        if (
            airdropStatus || presaleStatus || seedsaleStatus || publicsaleStatus
        ) {
            revert SalesCountinue();
        }

        uint256 remainderAirdropBalance = AIRDROP_AMOUNT - airdropBuyed;
        AIRDROP_AMOUNT = airdropBuyed;
        uint256 remainderSeedsaleBalance = SEEDSALE_AMOUNT - seedsaleBuyed;
        SEEDSALE_AMOUNT = seedsaleBuyed;
        uint256 remainderPresaleBalance = PRESALE_AMOUNT - presaleBuyed;
        PRESALE_AMOUNT = presaleBuyed;
        PUBLICSALE_AMOUNT =
            PUBLICSALE_AMOUNT +
            remainderAirdropBalance +
            remainderSeedsaleBalance +
            remainderPresaleBalance;

        emit TransferToPublic(PUBLICSALE_AMOUNT);
    }

    /**
     * @notice Withdraw the contract balance to the contract owner.
     * @dev Only the contract owner can withdraw the contract balance to their address.
     * emit OwnerWithdrawCoin is an event that is emitted when the contract owner withdraws the contract balance to their address.
     */
    function withdrawCoin() public onlyOwner {
        uint256 amount = address(this).balance;

        (bool success, bytes memory data) = msg.sender.call{value: amount}("");
        if (!success) {
            revert WithdrawalFailed();
        }

        emit OwnerWithdrawCoin(amount, data);
    }

    /**
     * @notice Withdraw the contract token balance to the contract owner.
     * @dev Only the contract owner can withdraw the contract token balance to their address.
     * emit OwnerWithdrawToken is an event that is emitted when the contract owner withdraws the contract token balance to their address.
     */
    function withdrawToken() public onlyOwner {
        uint256 amount = token.balanceOf(address(this));

        isTokenBalanceOk = false;
        token.safeTransfer(msg.sender, amount);

        emit OwnerWithdrawToken(amount);
    }

    // </ Only Owner Functions >
    // < Public Functions >
    /**
     * @notice Buy Airdrop tokens.
     * @dev This function allows users to buy Airdrop tokens if the sale is active and their address is verified by the provided Merkle proof.
     * @param _merkleProof Merkle proof for the user's address.
     * emit AirdropBuyed is an event that is emitted when the user buys Airdrop tokens.
     */
    function buyAirdrop(
        bytes32[] calldata _merkleProof
    ) external isAirdropStarted {
        if (!_verifyAirdrop(_merkleProof)) {
            revert InvalidMerkleProof();
        }
        if (_verifyAirdropAmount()) {
            revert AirdropAlreadyBuyed();
        }
        if (airdropBuyed + AIRDROP_MAX_PER_WALLET > AIRDROP_AMOUNT) {
            revert AirdropSoldOut();
        }

        airdropBalances[msg.sender] += AIRDROP_MAX_PER_WALLET;
        airdropBuyed += AIRDROP_MAX_PER_WALLET;

        emit AirdropBuyed(msg.sender, AIRDROP_MAX_PER_WALLET);
    }

    /**
     * @notice Buy Seedsale tokens.
     * @dev This function allows users to buy Seedsale tokens if the sale is active and their address is verified by the provided Merkle proof.
     * @param _merkleProof Merkle proof for the user's address.
     * @param _amount Amount of tokens to buy.
     * emit SeedsaleBuyed is an event that is emitted when the user buys Seedsale tokens.
     */
    function buySeedsale(
        bytes32[] calldata _merkleProof,
        uint256 _amount
    ) external payable isSeedsaleStarted checkZeroAmount(_amount) {
        if (_amount <= SEEDSALE_CLAIM_PERIOD) {
            revert InvalidAmount();
        }
        if (!_verifySeedsale(_merkleProof)) {
            revert InvalidMerkleProof();
        }
        if (_verifySeedsaleAmount(_amount)) {
            revert SeedsaleMaxPerWalletExceeded();
        }
        if (seedsaleBuyed + _amount > SEEDSALE_AMOUNT) {
            revert SeedsaleSoldOut();
        }
        if (msg.value != _amount * SEEDSALE_PRICE) {
            revert InvalidBalance();
        }

        seedsaleBalances[msg.sender] += _amount;
        seedsaleBuyed += _amount;

        emit SeedsaleBuyed(msg.sender, _amount);
    }

    /**
     * @notice Buy Presale tokens.
     * @dev This function allows users to buy Presale tokens if the sale is active and their address is verified by the provided Merkle proof.
     * @param _merkleProof Merkle proof for the user's address.
     * @param _amount Amount of tokens to buy.
     * emit PresaleBuyed is an event that is emitted when the user buys Presale tokens.
     */
    function buyPresale(
        bytes32[] calldata _merkleProof,
        uint256 _amount
    ) external payable isPresaleStarted checkZeroAmount(_amount) {
        if (_amount <= PRESALE_CLAIM_PERIOD) {
            revert InvalidAmount();
        }
        if (!_verifyPresale(_merkleProof)) {
            revert InvalidMerkleProof();
        }
        if (_verifyPresaleAmount(_amount)) {
            revert PresaleMaxPerWalletExceeded();
        }
        if (presaleBuyed + _amount > PRESALE_AMOUNT) {
            revert PresaleSoldOut();
        }
        if (msg.value != _amount * PRESALE_PRICE) {
            revert InvalidBalance();
        }

        presaleBalances[msg.sender] += _amount;
        presaleBuyed += _amount;

        emit PresaleBuyed(msg.sender, _amount);
    }

    /**
     * @notice Buy Publicsale tokens.
     * @dev This function allows users to buy Publicsale tokens if the sale is active.
     * @param _amount Amount of tokens to buy.
     * emit PublicsaleBuyed is an event that is emitted when the user buys Publicsale tokens.
     */
    function buyPublicsale(
        uint256 _amount
    ) external payable isPublicsaleStarted checkZeroAmount(_amount) {
        if (_amount <= PUBLICSALE_CLAIM_PERIOD) {
            revert InvalidAmount();
        }
        if (_verifyPublicsaleAmount(_amount)) {
            revert PublicsaleMaxPerWalletExceeded();
        }
        if (publicsaleBuyed + _amount > PUBLICSALE_AMOUNT) {
            revert PublicsaleSoldOut();
        }
        if (msg.value != _amount * PUBLICSALE_PRICE) {
            revert InvalidBalance();
        }

        publicsaleBalances[msg.sender] += _amount;
        publicsaleBuyed += _amount;

        emit PublicsaleBuyed(msg.sender, _amount);
    }

    /**
     * @notice Claim Airdrop tokens for a specific period.
     * @dev Users can claim Airdrop tokens for a specific period if they meet the conditions.
     * @param _period The claim period.
     * emit AirdropClaimed is an event that is emitted when the user claims Airdrop tokens.
     */
    function claimAirdrop(uint256 _period) external nonReentrant {
        if (_period == 0 || _period > AIRDROP_CLAIM_PERIOD) {
            revert InvalidPeriod();
        }
        if (
            block.timestamp < AIRDROP_CLAIM_START_TIME + _period * PERIOD_TIME
        ) {
            revert AirdropClaimPeriodNotStarted();
        }
        if (airdropBalances[msg.sender] == 0) {
            revert ZeroBalance();
        }
        if (_period != 1 && airdropClaimedPerPeriod[msg.sender][1] == 0) {
            revert BeforeClaimFirstPeriod();
        }
        if (airdropClaimedPerPeriod[msg.sender][_period] > 0) {
            revert AirdropAlreadyClaimed();
        }

        uint256 amount;

        if (_period == 1) {
            amount = (airdropBalances[msg.sender] / AIRDROP_CLAIM_PERIOD);
        } else if (_period == AIRDROP_CLAIM_PERIOD) {
            amount = airdropBalances[msg.sender];
        } else {
            amount = airdropClaimedPerPeriod[msg.sender][1];
        }

        uint256 bigIntAmount = amount * 10 ** 18;

        airdropClaimedPerPeriod[msg.sender][_period] = amount;
        airdropBalances[msg.sender] -= amount;
        token.transfer(msg.sender, bigIntAmount);

        emit AirdropClaimed(msg.sender, bigIntAmount);
    }

    /**
     * @notice Claim Seed Sale tokens for a specific period.
     * @dev Users can claim Seed Sale tokens for a specific period if they meet the conditions.
     * @param _period The claim period (1 to SEEDSALE_CLAIM_PERIOD).
     * emit SeedsaleClaimed is an event that is emitted when the user claims Seed Sale tokens.
     */
    function claimSeedsale(uint256 _period) external nonReentrant {
        if (_period == 0 || _period > SEEDSALE_CLAIM_PERIOD) {
            revert InvalidPeriod();
        }
        if (
            block.timestamp < SEEDSALE_CLAIM_START_TIME + _period * PERIOD_TIME
        ) {
            revert SeedsaleClaimPeriodNotStarted();
        }
        if (seedsaleBalances[msg.sender] == 0) {
            revert ZeroBalance();
        }
        if (_period != 1 && seedsaleClaimedPerPeriod[msg.sender][1] == 0) {
            revert BeforeClaimFirstPeriod();
        }
        if (seedsaleClaimedPerPeriod[msg.sender][_period] > 0) {
            revert SeedsaleAlreadyClaimed();
        }

        uint256 amount;

        if (_period == 1) {
            amount = seedsaleBalances[msg.sender] / SEEDSALE_CLAIM_PERIOD;
        } else if (_period == SEEDSALE_CLAIM_PERIOD) {
            amount = seedsaleBalances[msg.sender];
        } else {
            amount = seedsaleClaimedPerPeriod[msg.sender][1];
        }

        uint256 bigIntAmount = amount * 10 ** 18;

        seedsaleClaimedPerPeriod[msg.sender][_period] = amount;
        seedsaleBalances[msg.sender] -= amount;
        token.transfer(msg.sender, bigIntAmount);

        emit SeedsaleClaimed(msg.sender, bigIntAmount);
    }

    /**
     * @notice Claim Presale tokens for a specific period.
     * @dev Users can claim Presale tokens for a specific period if they meet the conditions.
     * @param _period The claim period.
     * emit PresaleClaimed is an event that is emitted when the user claims Presale tokens.
     */
    function claimPresale(uint256 _period) external nonReentrant {
        if (_period == 0 || _period > PRESALE_CLAIM_PERIOD) {
            revert InvalidPeriod();
        }
        if (
            block.timestamp < PRESALE_CLAIM_START_TIME + _period * PERIOD_TIME
        ) {
            revert PresaleClaimPeriodNotStarted();
        }
        if (presaleBalances[msg.sender] == 0) {
            revert ZeroBalance();
        }
        if (_period != 1 && presaleClaimedPerPeriod[msg.sender][1] == 0) {
            revert BeforeClaimFirstPeriod();
        }
        if (presaleClaimedPerPeriod[msg.sender][_period] > 0) {
            revert PresaleAlreadyClaimed();
        }

        uint256 amount;

        if (_period == 1) {
            amount = presaleBalances[msg.sender] / PRESALE_CLAIM_PERIOD;
        } else if (_period == PRESALE_CLAIM_PERIOD) {
            amount = presaleBalances[msg.sender];
        } else {
            amount = presaleClaimedPerPeriod[msg.sender][1];
        }

        uint256 bigIntAmount = amount * 10 ** 18;

        presaleClaimedPerPeriod[msg.sender][_period] = amount;
        presaleBalances[msg.sender] -= amount;
        token.transfer(msg.sender, bigIntAmount);

        emit PresaleClaimed(msg.sender, bigIntAmount);
    }

    /**
     * @notice Claim Public Sale tokens for a specific period.
     * @dev Users can claim Public Sale tokens for a specific period if they meet the conditions.
     * @param _period The claim period.
     * emit PublicsaleClaimed is an event that is emitted when the user claims Public Sale tokens.
     */
    function claimPublicsale(uint256 _period) external nonReentrant {
        if (_period == 0 || _period > PUBLICSALE_CLAIM_PERIOD) {
            revert InvalidPeriod();
        }
        if (
            block.timestamp <
            PUBLICSALE_CLAIM_START_TIME + _period * PERIOD_TIME
        ) {
            revert PublicsaleClaimPeriodNotStarted();
        }
        if (publicsaleBalances[msg.sender] == 0) {
            revert ZeroBalance();
        }
        if (_period != 1 && publicsaleClaimedPerPeriod[msg.sender][1] == 0) {
            revert BeforeClaimFirstPeriod();
        }
        if (publicsaleClaimedPerPeriod[msg.sender][_period] > 0) {
            revert PublicsaleAlreadyClaimed();
        }

        uint256 amount;

        if (_period == 1) {
            amount = publicsaleBalances[msg.sender] / PUBLICSALE_CLAIM_PERIOD;
        } else if (_period == PUBLICSALE_CLAIM_PERIOD) {
            amount = publicsaleBalances[msg.sender];
        } else {
            amount = publicsaleClaimedPerPeriod[msg.sender][1];
        }

        uint256 bigIntAmount = amount * 10 ** 18;

        publicsaleClaimedPerPeriod[msg.sender][_period] = amount;
        publicsaleBalances[msg.sender] -= amount;
        token.transfer(msg.sender, bigIntAmount);

        emit PublicsaleClaimed(msg.sender, bigIntAmount);
    }

    // </ Public Functions >

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
