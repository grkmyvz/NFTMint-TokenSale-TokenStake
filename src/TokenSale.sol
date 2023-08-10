// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

/**
 * @title TokenSale
 * @dev A contract for managing a token sale with different phases (airdrop, presale, seedsale, publicsale).
 */
contract TokenSale is Ownable, ReentrancyGuard {
    IERC20 public token;

    // THIS VARIBALES CAN BE CHANGED //
    uint256 public AIRDROP_AMOUNT = 20 * 10 ** 18;
    uint256 public AIRDROP_MAX_PER_WALLET = 10 * 10 ** 18;
    uint256 public AIRDROP_CLAIM_START_TIME = 100;
    uint256 public AIRDROP_CLAIM_PERIOD = 5;
    uint256 public PRESALE_AMOUNT = 20 * 10 ** 18;
    uint256 public PRESALE_MAX_PER_WALLET = 20 * 10 ** 18;
    uint256 public PRESALE_PRICE = 1;
    uint256 public PRESALE_CLAIM_START_TIME = 200;
    uint256 public PRESALE_CLAIM_PERIOD = 5;
    uint256 public SEEDSALE_AMOUNT = 20 * 10 ** 18;
    uint256 public SEEDSALE_MAX_PER_WALLET = 30 * 10 ** 18;
    uint256 public SEEDSALE_PRICE = 2;
    uint256 public SEEDSALE_CLAIM_START_TIME = 300;
    uint256 public SEEDSALE_CLAIM_PERIOD = 5;
    uint256 public PUBLICSALE_AMOUNT = 20 * 10 ** 18;
    uint256 public PUBLICSALE_MAX_PER_WALLET = 50 * 10 ** 18;
    uint256 public PUBLICSALE_PRICE = 3;
    uint256 public PUBLICSALE_CLAIM_START_TIME = 400;
    uint256 public PUBLICSALE_CLAIM_PERIOD = 5;
    uint256 public PERIOD_TIME = 10; // TODO: Change this to the actual date (Example 1 mount = 2629743 seconds)
    // THIS VARIBALES CAN BE CHANGED //

    uint256 public airdropBuyed;
    uint256 public presaleBuyed;
    uint256 public seedsaleBuyed;
    uint256 public publicsaleBuyed;

    mapping(address => uint256) public airdropBalances;
    mapping(address => uint256) public presaleBalances;
    mapping(address => uint256) public seedsaleBalances;
    mapping(address => uint256) public publicsaleBalances;

    mapping(address => mapping(uint256 => uint256))
        public airdropClaimedPerPeriod;
    mapping(address => mapping(uint256 => uint256))
        public presaleClaimedPerPeriod;
    mapping(address => mapping(uint256 => uint256))
        public seedsaleClaimedPerPeriod;
    mapping(address => mapping(uint256 => uint256))
        public publicsaleClaimedPerPeriod;

    bool public isTokenBalanceOk = false;
    bool public isAirdropStarted = false;
    bool public isPresaleStarted = false;
    bool public isSeedsaleStarted = false;
    bool public isPublicsaleStarted = false;

    bytes32 public airdropMerkleRoot;
    bytes32 public presaleMerkleRoot;
    bytes32 public seedsaleMerkleRoot;

    constructor(address _tokenAddress) {
        if (_tokenAddress == address(0)) {
            revert("InvalidTokenAddress");
        }

        token = IERC20(_tokenAddress);
    }

    modifier airdropStarted() {
        if (!isAirdropStarted && !isTokenBalanceOk) {
            revert("AirdropNotStarted");
        }
        _;
    }

    modifier presaleStarted() {
        if (!isPresaleStarted && !isTokenBalanceOk) {
            revert("PresaleNotStarted");
        }
        _;
    }

    modifier seedsaleStarted() {
        if (!isSeedsaleStarted && !isTokenBalanceOk) {
            revert("SeedsaleNotStarted");
        }
        _;
    }

    modifier publicsaleStarted() {
        if (!isPublicsaleStarted && !isTokenBalanceOk) {
            revert("PublicsaleNotStarted");
        }
        _;
    }

    /**
     * @notice Sends tokens to the contract.
     * @dev Only the contract owner can use this function to send tokens for the sale and marks the token balance as ready.
     * @param _amount The total amount of tokens to be sent for the sale.
     */
    function sendTokens(uint256 _amount) external onlyOwner {
        if (isTokenBalanceOk) {
            revert("TokenBalanceAlreadyOk");
        }
        if (
            AIRDROP_AMOUNT +
                PRESALE_AMOUNT +
                SEEDSALE_AMOUNT +
                PUBLICSALE_AMOUNT !=
            _amount
        ) {
            revert("InvalidAmount");
        }

        token.transferFrom(msg.sender, address(this), _amount);
        isTokenBalanceOk = true;
    }

    /**
     * @notice Change airdrop merkle root.
     * @dev Only the contract owner can change the merkle root for the airdrop.
     * @param _merkleRoot New merkle root for the airdrop.
     */
    function setAirdropMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        airdropMerkleRoot = _merkleRoot;
    }

    /**
     * @notice Change presale merkle root.
     * @dev Only the contract owner can change the merkle root for the presale.
     * @param _merkleRoot New merkle root for the presale.
     */
    function setPresaleMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        presaleMerkleRoot = _merkleRoot;
    }

    /**
     * @notice Change seedsale merkle root.
     * @dev Only the contract owner can change the merkle root hash for the seedsale.
     * @param _merkleRoot New merkle root for the seedsale.
     */
    function setSeedsaleMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        seedsaleMerkleRoot = _merkleRoot;
    }

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
     * @notice Start the Airdrop sale phase.
     * @dev Only the contract owner can start the Airdrop sale.
     */
    function setStartAirdrop() external onlyOwner {
        isAirdropStarted = true;
    }

    /**
     * @notice Start the Presale phase.
     * @dev Only the contract owner can start the Presale phase.
     */
    function setStartPresale() external onlyOwner {
        isPresaleStarted = true;
    }

    /**
     * @notice Start the Seedsale phase.
     * @dev Only the contract owner can start the Seedsale phase.
     */
    function setStartSeedsale() external onlyOwner {
        isSeedsaleStarted = true;
    }

    /**
     * @notice Start the Publicsale phase.
     * @dev Only the contract owner can start the Publicsale phase.
     */
    function setStartPublicsale() external onlyOwner {
        isPublicsaleStarted = true;
    }

    /**
     * @notice Buy Airdrop tokens.
     * @dev This function allows users to buy Airdrop tokens if the sale is active and their address is verified by the provided Merkle proof.
     * @param _merkleProof Merkle proof for the user's address.
     */
    function buyAirdrop(
        bytes32[] calldata _merkleProof
    ) external airdropStarted {
        if (!_verifyAirdrop(_merkleProof)) {
            revert("InvalidMerkleProof");
        }
        if (airdropBalances[msg.sender] == AIRDROP_MAX_PER_WALLET) {
            revert("AirdropAlreadyBuyed");
        }
        if (airdropBuyed + AIRDROP_MAX_PER_WALLET > AIRDROP_AMOUNT) {
            revert("AirdropSoldOut");
        }

        airdropBalances[msg.sender] += AIRDROP_MAX_PER_WALLET;
        airdropBuyed += AIRDROP_MAX_PER_WALLET;

        emit AirdropBuyed(msg.sender, AIRDROP_MAX_PER_WALLET);
    }

    /**
     * @notice Buy Presale tokens.
     * @dev This function allows users to buy Presale tokens if the sale is active and their address is verified by the provided Merkle proof.
     * @param _merkleProof Merkle proof for the user's address.
     * @param _amount Amount of tokens to buy.
     */
    function buyPresale(
        bytes32[] calldata _merkleProof,
        uint256 _amount
    ) external payable presaleStarted {
        if (!_verifyPresale(_merkleProof)) {
            revert("InvalidMerkleProof");
        }
        if (presaleBalances[msg.sender] + _amount > PRESALE_MAX_PER_WALLET) {
            revert("PresaleMaxPerWalletExceeded");
        }
        if (presaleBuyed + _amount > PRESALE_AMOUNT) {
            revert("PresaleSoldOut");
        }
        if (msg.value != _amount * PRESALE_PRICE) {
            revert("InvalidBalance");
        }

        presaleBalances[msg.sender] += _amount;
        presaleBuyed += _amount;

        emit PresaleBuyed(msg.sender, _amount);
    }

    /**
     * @notice Buy Seedsale tokens.
     * @dev This function allows users to buy Seedsale tokens if the sale is active and their address is verified by the provided Merkle proof.
     * @param _merkleProof Merkle proof for the user's address.
     * @param _amount Amount of tokens to buy.
     */
    function buySeedsale(
        bytes32[] calldata _merkleProof,
        uint256 _amount
    ) external payable seedsaleStarted {
        if (!_verifySeedsale(_merkleProof)) {
            revert("InvalidMerkleProof");
        }
        if (seedsaleBalances[msg.sender] + _amount > SEEDSALE_MAX_PER_WALLET) {
            revert("SeedsaleMaxPerWalletExceeded");
        }
        if (seedsaleBuyed + _amount > SEEDSALE_AMOUNT) {
            revert("SeedsaleSoldOut");
        }
        if (msg.value != _amount * SEEDSALE_PRICE) {
            revert("InvalidBalance");
        }

        seedsaleBalances[msg.sender] += _amount;
        seedsaleBuyed += _amount;

        emit SeedsaleBuyed(msg.sender, _amount);
    }

    /**
     * @notice Buy Publicsale tokens.
     * @dev This function allows users to buy Publicsale tokens if the sale is active.
     * @param _amount Amount of tokens to buy.
     */
    function buyPublicsale(uint256 _amount) external payable publicsaleStarted {
        if (
            publicsaleBalances[msg.sender] + _amount > PUBLICSALE_MAX_PER_WALLET
        ) {
            revert("PublicsaleMaxPerWalletExceeded");
        }
        if (publicsaleBuyed + _amount > PUBLICSALE_AMOUNT) {
            revert("PublicsaleSoldOut");
        }
        if (msg.value != _amount * PUBLICSALE_PRICE) {
            revert("InvalidBalance");
        }

        publicsaleBalances[msg.sender] += _amount;
        publicsaleBuyed += _amount;

        emit PublicsaleBuyed(msg.sender, _amount);
    }

    /**
     * @notice Claim Airdrop tokens for a specific period.
     * @dev Users can claim Airdrop tokens for a specific period if they meet the conditions.
     * @param _period The claim period.
     */
    function claimAirdrop(uint256 _period) external nonReentrant {
        if (_period <= 0 || _period > AIRDROP_CLAIM_PERIOD) {
            revert("InvalidPeriod");
        }
        if (block.timestamp < AIRDROP_CLAIM_START_TIME) {
            revert("AirdropClaimNotStarted");
        }
        if (
            block.timestamp < AIRDROP_CLAIM_START_TIME + _period * PERIOD_TIME
        ) {
            revert("AirdropClaimPeriodNotStarted");
        }
        if (airdropBalances[msg.sender] == 0) {
            revert("AirdropBalanceZero");
        }
        if (_period != 1 && airdropClaimedPerPeriod[msg.sender][1] == 0) {
            revert("BeforeClaimFirstPeriod");
        }
        if (airdropClaimedPerPeriod[msg.sender][_period] > 0) {
            revert("AirdropAlreadyClaimed");
        }

        uint256 amount;

        if (_period == 1) {
            amount = airdropBalances[msg.sender] / AIRDROP_CLAIM_PERIOD;
        } else {
            amount = airdropClaimedPerPeriod[msg.sender][1];
        }

        airdropClaimedPerPeriod[msg.sender][_period] = amount;
        airdropBalances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);

        emit AirdropClaimed(msg.sender, amount);
    }

    /**
     * @notice Claim Presale tokens for a specific period.
     * @dev Users can claim Presale tokens for a specific period if they meet the conditions.
     * @param _period The claim period.
     */
    function claimPresale(uint256 _period) external nonReentrant {
        if (_period <= 0 || _period > PRESALE_CLAIM_PERIOD) {
            revert("InvalidPeriod");
        }
        if (block.timestamp < PRESALE_CLAIM_START_TIME) {
            revert("PresaleClaimNotStarted");
        }
        if (
            block.timestamp < PRESALE_CLAIM_START_TIME + _period * PERIOD_TIME
        ) {
            revert("PresaleClaimPeriodNotStarted");
        }
        if (presaleBalances[msg.sender] == 0) {
            revert("PresaleBalanceZero");
        }
        if (_period != 1 && presaleClaimedPerPeriod[msg.sender][1] == 0) {
            revert("BeforeClaimFirstPeriod");
        }
        if (presaleClaimedPerPeriod[msg.sender][_period] > 0) {
            revert("PresaleAlreadyClaimed");
        }

        uint256 amount;

        if (_period == 1) {
            amount = presaleBalances[msg.sender] / PRESALE_CLAIM_PERIOD;
        } else {
            amount = presaleClaimedPerPeriod[msg.sender][1];
        }

        presaleClaimedPerPeriod[msg.sender][_period] = amount;
        presaleBalances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);

        emit PresaleClaimed(msg.sender, amount);
    }

    /**
     * @notice Claim Seed Sale tokens for a specific period.
     * @dev Users can claim Seed Sale tokens for a specific period if they meet the conditions.
     * @param _period The claim period (1 to SEEDSALE_CLAIM_PERIOD).
     */
    function claimSeedsale(uint256 _period) external nonReentrant {
        if (_period <= 0 || _period > SEEDSALE_CLAIM_PERIOD) {
            revert("InvalidPeriod");
        }
        if (block.timestamp < SEEDSALE_CLAIM_START_TIME) {
            revert("SeedsaleClaimNotStarted");
        }
        if (
            block.timestamp < SEEDSALE_CLAIM_START_TIME + _period * PERIOD_TIME
        ) {
            revert("SeedsaleClaimPeriodNotStarted");
        }
        if (seedsaleBalances[msg.sender] == 0) {
            revert("SeedsaleBalanceZero");
        }
        if (_period != 1 && seedsaleClaimedPerPeriod[msg.sender][1] == 0) {
            revert("BeforeClaimFirstPeriod");
        }
        if (seedsaleClaimedPerPeriod[msg.sender][_period] > 0) {
            revert("SeedsaleAlreadyClaimed");
        }

        uint256 amount;

        if (_period == 1) {
            amount = seedsaleBalances[msg.sender] / SEEDSALE_CLAIM_PERIOD;
        } else {
            amount = seedsaleClaimedPerPeriod[msg.sender][1];
        }

        seedsaleClaimedPerPeriod[msg.sender][_period] = amount;
        seedsaleBalances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);

        emit SeedsaleClaimed(msg.sender, amount);
    }

    /**
     * @notice Claim Public Sale tokens for a specific period.
     * @dev Users can claim Public Sale tokens for a specific period if they meet the conditions.
     * @param _period The claim period (1 to PUBLICSALE_CLAIM_PERIOD).
     */
    function claimPublicsale(uint256 _period) external nonReentrant {
        if (_period <= 0 || _period > PUBLICSALE_CLAIM_PERIOD) {
            revert("InvalidPeriod");
        }
        if (block.timestamp < PUBLICSALE_CLAIM_START_TIME) {
            revert("PublicsaleClaimNotStarted");
        }
        if (
            block.timestamp <
            PUBLICSALE_CLAIM_START_TIME + _period * PERIOD_TIME
        ) {
            revert("PublicsaleClaimPeriodNotStarted");
        }
        if (publicsaleBalances[msg.sender] == 0) {
            revert("PublicsaleBalanceZero");
        }
        if (_period != 1 && publicsaleClaimedPerPeriod[msg.sender][1] == 0) {
            revert("BeforeClaimFirstPeriod");
        }
        if (publicsaleClaimedPerPeriod[msg.sender][_period] > 0) {
            revert("PublicsaleAlreadyClaimed");
        }

        uint256 amount;

        if (_period == 1) {
            amount = publicsaleBalances[msg.sender] / PUBLICSALE_CLAIM_PERIOD;
        } else {
            amount = publicsaleClaimedPerPeriod[msg.sender][1];
        }

        publicsaleClaimedPerPeriod[msg.sender][_period] = amount;
        publicsaleBalances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);

        emit PublicsaleClaimed(msg.sender, amount);
    }

    /**
     * @notice Withdraw the contract balance to the contract owner.
     * @dev Only the contract owner can withdraw the contract balance to their address.
     */
    function withdrawCoin() public onlyOwner {
        uint256 amount = address(this).balance;
        address projectOwner = owner();

        (bool success, bytes memory data) = projectOwner.call{value: amount}(
            ""
        );
        if (!success) {
            revert("WithdrawalFailed");
        }

        emit OwnerWithdrawCoin(projectOwner, amount, data);
    }

    function withdrawToken() public onlyOwner {
        uint256 amount = token.balanceOf(address(this));
        address projectOwner = owner();

        token.transfer(projectOwner, amount);

        emit OwnerWithdrawToken(projectOwner, amount);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    event AirdropBuyed(address indexed _buyer, uint256 _amount);
    event PresaleBuyed(address indexed _buyer, uint256 _amount);
    event SeedsaleBuyed(address indexed _buyer, uint256 _amount);
    event PublicsaleBuyed(address indexed _buyer, uint256 _amount);
    event AirdropClaimed(address indexed _buyer, uint256 _amount);
    event PresaleClaimed(address indexed _buyer, uint256 _amount);
    event SeedsaleClaimed(address indexed _buyer, uint256 _amount);
    event PublicsaleClaimed(address indexed _buyer, uint256 _amount);
    event OwnerWithdrawCoin(
        address indexed _owner,
        uint256 _amount,
        bytes _data
    );
    event OwnerWithdrawToken(address indexed _owner, uint256 _amount);
}
