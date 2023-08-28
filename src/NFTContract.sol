// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// This is Foundry version
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

/**
 * @title NFTName
 * @dev This is the main contract for the NFTName project.
 * @author --. --- .-. -.- . -- / -.-- .- ...- ..- --..
 */
contract NFTName is ERC721Enumerable, Ownable, ReentrancyGuard {
    ///////////////////////////
    // Errors
    ///////////////////////////
    error FreeMintNotStarted();
    error FreeMintFinished();
    error WhitelistMintNotStarted();
    error WhitelistMintFinished();
    error PublicMintNotStarted();
    error MintingStopped();
    error InvalidFreeMintTime();
    error InvalidWhitelistMintTime();
    error InvalidPublicMintTime();
    error CanNotChangePrice();
    error InvalidAddress();
    error InvalidAmount();
    error OverflowMaxSupply();
    error HaveNotEligible();
    error InsufficientBalance();
    error FreeMintLimitExceeded();
    error WhitelistMintLimitExceeded();
    error PublicMintLimitExceeded();
    error YouNotTokenHolder();
    error WithdrawalFailed();

    ///////////////////////////
    // Types
    ///////////////////////////
    using Counters for Counters.Counter;
    using Strings for uint256;

    ///////////////////////////
    // State Variables
    ///////////////////////////
    // THIS VARIBALES CAN BE CHANGED //
    uint256 public MAX_SUPPLY = 1000; // Maximum number of tokens that can be minted.
    uint256 public FREE_START = 2; // Timestamp for the start of the free stage.
    uint256 public FREE_STOP = 4; // Timestamp for the end of the free stage.
    uint256 public FREE_PER_WALLET = 2; // Maximum number of tokens that can be minted per wallet during the free stage.
    uint256 public WHITELIST_START = 5; // Timestamp for the start of the whitelist stage.
    uint256 public WHITELIST_STOP = 8; // Timestamp for the end of the whitelist stage.
    uint256 public WHITELIST_PER_WALLET = 10; // Maximum number of tokens that can be minted per wallet during the whitelist stage.
    uint256 public WHITELIST_PRICE = 0.1 ether; // Price of each token during the whitelist stage.
    uint256 public PUBLIC_START = 9; // Timestamp for the start of the public sale stage.
    uint256 public PUBLIC_PER_WALLET = 5; // Maximum number of tokens that can be minted per wallet during the public sale stage.
    uint256 public PUBLIC_PRICE = 0.2 ether; // Price of each token during the public sale stage.
    string public BASE_URL = "https://localhost/"; // Base URL for token metadata.
    // THIS VARIBALES CAN BE CHANGED //

    bool public MINT_STATUS;

    bytes32 public freeMerkleRoot;
    bytes32 public whitelistMerkleRoot;

    mapping(address => uint256) private _freeClaimed;
    mapping(address => uint256) private _whitelistClaimed;
    mapping(address => uint256) private _publicClaimed;

    Counters.Counter private _tokenIdCounter;

    ///////////////////////////
    // Events
    ///////////////////////////
    event ChangedTimes(
        uint256 _freeStart,
        uint256 _freeStop,
        uint256 _whitelistStart,
        uint256 _whitelistStop,
        uint256 _publicStart
    );
    event ChangedMintStatus(bool _status);
    event ChangedPrices(uint256 _whitelistPrice, uint256 _publicPrice);
    event MintedForOwner(address indexed _to, uint256 _qty);
    event MintedForFree(address indexed _to, uint256 _qty);
    event MintedForWhitelist(address indexed _to, uint256 _qty);
    event MintedForPublic(address indexed _to, uint256 _qty);
    event Withdraw(address indexed _to, uint256 _amount, bytes _data);

    ///////////////////////////
    // Modifiers
    ///////////////////////////
    modifier isFreeStart() {
        if (block.timestamp < FREE_START) {
            revert FreeMintNotStarted();
        } else if (block.timestamp > FREE_STOP) {
            revert FreeMintFinished();
        } else if (MINT_STATUS) {
            revert MintingStopped();
        }
        _;
    }

    modifier isWhitelistStart() {
        if (block.timestamp < WHITELIST_START) {
            revert WhitelistMintNotStarted();
        } else if (block.timestamp > WHITELIST_STOP) {
            revert WhitelistMintFinished();
        } else if (MINT_STATUS) {
            revert MintingStopped();
        }
        _;
    }

    modifier isPublicStart() {
        if (block.timestamp < PUBLIC_START) {
            revert PublicMintNotStarted();
        } else if (MINT_STATUS) {
            revert MintingStopped();
        }
        _;
    }

    modifier checkZeroAmount(uint256 _amount) {
        if (_amount <= 0) {
            revert InvalidAmount();
        }
        _;
    }

    modifier checkMaxSupply(uint256 _amount) {
        if ((_tokenIdCounter.current() + _amount) > MAX_SUPPLY) {
            revert OverflowMaxSupply();
        }
        _;
    }

    ///////////////////////////
    // Functions
    ///////////////////////////
    // Change this name and symbol
    constructor() ERC721("Token Name2", "TNS2") {
        if (
            block.timestamp > FREE_START ||
            FREE_START >= FREE_STOP ||
            FREE_START > WHITELIST_START
        ) {
            revert InvalidFreeMintTime();
        }
        if (
            WHITELIST_START >= WHITELIST_STOP || WHITELIST_STOP > PUBLIC_START
        ) {
            revert InvalidWhitelistMintTime();
        }
        if (WHITELIST_PRICE <= 0 || PUBLIC_PRICE <= 0) {
            revert InvalidAmount();
        }
        if (WHITELIST_PRICE > PUBLIC_PRICE) {
            revert InvalidAmount();
        }
    }

    // < Private Functions >
    /**
     * @dev _verifyFreelist is a function to verify the eligibility of the freelist.
     * @param _merkleProof is a proof of the freelist.
     * @return bool is a result of the verification.
     */
    function _verifyFreelist(
        bytes32[] calldata _merkleProof
    ) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, freeMerkleRoot, leaf);
    }

    /**
     * @dev _verifyWhitelist is a function to verify the eligibility of the whitelist.
     * @param _merkleProof is a proof of the whitelist.
     * @return bool is a result of the verification.
     */
    function _verifyWhitelist(
        bytes32[] calldata _merkleProof
    ) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, whitelistMerkleRoot, leaf);
    }

    // </ Private Functions >
    // < Get Functions >
    /**
     * @dev _baseURI is a function to get the base URI.
     * @return string is a base URI.
     */
    function _baseURI() internal view override returns (string memory) {
        return BASE_URL;
    }

    /**
     * @dev tokenURI is a function to get the token URI.
     * @param tokenId is a token ID.
     * @return string is a token URI.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    /**
     * @dev isMinted is a function to check if the token is minted.
     * @param tokenId is a token ID.
     * @return bool is a result of the check.
     */
    function isMinted(uint256 tokenId) external view returns (bool) {
        if (_exists(tokenId)) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev getTokenListByOwner is a function to get the token list by owner.
     * @param _tokenOwner is a token owner.
     * @return uint256[] is a token list.
     */
    function getTokenListByOwner(
        address _tokenOwner
    ) public view returns (uint256[] memory) {
        uint256 totalTokens = balanceOf(_tokenOwner);

        uint256[] memory ownedTokens = new uint256[](totalTokens);
        for (uint256 i = 0; i < totalTokens; i++) {
            ownedTokens[i] = tokenOfOwnerByIndex(_tokenOwner, i);
        }

        return ownedTokens;
    }

    // </ Get Functions >
    // < Only Owner Functions >
    /**
     * @dev setFreelistRoot is a function to set the freelist root.
     * @param _merkleRootHash is a merkle root hash.
     */
    function setFreelistRoot(bytes32 _merkleRootHash) external onlyOwner {
        freeMerkleRoot = _merkleRootHash;
    }

    /**
     * @dev setWhitelistRoot is a function to set the whitelist root.
     * @param _merkleRootHash is a merkle root hash.
     */
    function setWhitelistRoot(bytes32 _merkleRootHash) external onlyOwner {
        whitelistMerkleRoot = _merkleRootHash;
    }

    /**
     * @dev setBaseUrl is a function to set the base URL.
     * @param _url is a base URL.
     */
    function setBaseUrl(string memory _url) external onlyOwner {
        BASE_URL = _url;
    }

    /**
     * @dev setTimes is a function to set the times.
     * @param _freeStart is a timestamp for the start of the free stage.
     * @param _freeStop is a timestamp for the end of the free stage.
     * @param _whitelistStart is a timestamp for the start of the whitelist stage.
     * @param _whitelistStop is a timestamp for the end of the whitelist stage.
     * @param _publicStart is a timestamp for the start of the public sale stage.
     * emit ChangedTimes is an event that is emitted when the times are changed.
     */
    function setTimes(
        uint256 _freeStart,
        uint256 _freeStop,
        uint256 _whitelistStart,
        uint256 _whitelistStop,
        uint256 _publicStart
    ) external onlyOwner {
        if (
            block.timestamp > _freeStart ||
            _freeStart >= _freeStop ||
            _freeStop > _whitelistStart
        ) {
            revert InvalidFreeMintTime();
        }
        if (
            _whitelistStart >= _whitelistStop || _whitelistStop > _publicStart
        ) {
            revert InvalidWhitelistMintTime();
        }

        FREE_START = _freeStart;
        FREE_STOP = _freeStop;
        WHITELIST_START = _whitelistStart;
        WHITELIST_STOP = _whitelistStop;
        PUBLIC_START = _publicStart;

        emit ChangedTimes(
            _freeStart,
            _freeStop,
            _whitelistStart,
            _whitelistStop,
            _publicStart
        );
    }

    /**
     * @dev setPrices is a function to set the prices.
     * @param _whitelistPrice is a price of each token during the whitelist stage.
     * @param _publicPrice is a price of each token during the public sale stage.
     * emit ChangedPrices is an event that is emitted when the prices are changed.
     */
    function setPrices(
        uint256 _whitelistPrice,
        uint256 _publicPrice
    ) external onlyOwner {
        if (_whitelistPrice <= 0 || _publicPrice <= 0) {
            revert InvalidAmount();
        }
        if (_whitelistPrice > _publicPrice) {
            revert InvalidAmount();
        }
        if (
            block.timestamp > WHITELIST_START || block.timestamp > PUBLIC_START
        ) {
            revert CanNotChangePrice();
        }

        WHITELIST_PRICE = _whitelistPrice;
        PUBLIC_PRICE = _publicPrice;

        emit ChangedPrices(_whitelistPrice, _publicPrice);
    }

    /**
     * @dev setMintStatus is a function to set the mint status.
     * @param _status is a mint status.
     * emit ChangedMintStatus is an event that is emitted when the mint status is changed.
     */
    function setMintStatus(bool _status) external onlyOwner {
        MINT_STATUS = _status;

        emit ChangedMintStatus(_status);
    }

    /**
     * @dev ownerMint is a function to mint tokens by owner.
     * @param _qty is a quantity of tokens to mint.
     */
    function ownerMint(
        uint256 _qty
    ) external onlyOwner checkZeroAmount(_qty) checkMaxSupply(_qty) {
        for (uint256 i = 0; i < _qty; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }

        emit MintedForOwner(msg.sender, _qty);
    }

    /**
     * @dev withdrawMoney is a function to withdraw money.
     * emit Withdraw is an event that is emitted when the money is withdrawn.
     */
    function withdrawMoney() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, bytes memory data) = msg.sender.call{value: amount}("");
        if (!success) {
            revert WithdrawalFailed();
        }

        emit Withdraw(msg.sender, amount, data);
    }

    // </ Only Owner Functions >
    // < Public Functions >
    /**
     * @dev freeMint is a function to mint tokens for free.
     * @param _merkleProof is a proof of the freelist.
     * @param _qty is a quantity of tokens to mint.
     * emit MintedForFree is an event that is emitted when the tokens are minted for free.
     */
    function freeMint(
        bytes32[] calldata _merkleProof,
        uint256 _qty
    )
        external
        nonReentrant
        isFreeStart
        checkZeroAmount(_qty)
        checkMaxSupply(_qty)
    {
        if (!_verifyFreelist(_merkleProof)) {
            revert HaveNotEligible();
        }
        if ((_freeClaimed[msg.sender] + _qty) > FREE_PER_WALLET) {
            revert FreeMintLimitExceeded();
        }

        for (uint256 i = 0; i < _qty; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _freeClaimed[msg.sender]++;
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }

        emit MintedForFree(msg.sender, _qty);
    }

    /**
     * @dev whitelistMint is a function to mint tokens for whitelist.
     * @param _merkleProof is a proof of the whitelist.
     * @param _qty is a quantity of tokens to mint.
     * emit MintedForWhitelist is an event that is emitted when the tokens are minted for whitelist.
     */
    function whitelistMint(
        bytes32[] calldata _merkleProof,
        uint256 _qty
    )
        external
        payable
        nonReentrant
        isWhitelistStart
        checkZeroAmount(_qty)
        checkMaxSupply(_qty)
    {
        if (!_verifyWhitelist(_merkleProof)) {
            revert HaveNotEligible();
        }
        if ((_whitelistClaimed[msg.sender] + _qty) > WHITELIST_PER_WALLET) {
            revert WhitelistMintLimitExceeded();
        }
        if (msg.value != (_qty * WHITELIST_PRICE)) {
            revert InsufficientBalance();
        }

        for (uint256 i = 0; i < _qty; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _whitelistClaimed[msg.sender]++;
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }

        emit MintedForWhitelist(msg.sender, _qty);
    }

    /**
     * @dev publicMint is a function to mint tokens for public.
     * @param _qty is a quantity of tokens to mint.
     * emit MintedForPublic is an event that is emitted when the tokens are minted for public.
     */
    function publicMint(
        uint256 _qty
    )
        external
        payable
        nonReentrant
        isPublicStart
        checkZeroAmount(_qty)
        checkMaxSupply(_qty)
    {
        if ((_publicClaimed[msg.sender] + _qty) > PUBLIC_PER_WALLET) {
            revert PublicMintLimitExceeded();
        }
        if (msg.value != (_qty * PUBLIC_PRICE)) {
            revert InsufficientBalance();
        }

        for (uint256 i = 0; i < _qty; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _publicClaimed[msg.sender]++;
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }

        emit MintedForPublic(msg.sender, _qty);
    }

    /**
     * @dev multipleTransfer is a function to transfer multiple tokens.
     * @param _to is a recipient of the tokens.
     * @param _tokenIds is a list of token IDs.
     */
    function multipleTransfer(
        address _to,
        uint256[] memory _tokenIds
    ) external nonReentrant {
        if (_to == address(0) || _to == msg.sender) {
            revert InvalidAddress();
        }
        uint256 tokenIdsLength = _tokenIds.length;
        if (tokenIdsLength <= 1) {
            revert InvalidAmount();
        }

        for (uint256 i = 0; i < tokenIdsLength; i++) {
            _requireMinted(_tokenIds[i]);
            if (ownerOf(_tokenIds[i]) != msg.sender) {
                revert YouNotTokenHolder();
            }
        }

        for (uint256 i = 0; i < tokenIdsLength; i++) {
            _transfer(msg.sender, _to, _tokenIds[i]);
        }
    }

    // </ Public Functions >

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
