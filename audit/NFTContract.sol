// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// This is Foundry version
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

// This is Remix IDE version
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title NFTName
 * @dev This is the main contract for the NFTName project.
 * @author --. --- .-. -.- . -- / -.-- .- ...- ..- --..
 */
contract NFTName is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // THIS VARIBALES CAN BE CHANGED //
    uint256 public MAX_SUPPLY = 1000;
    uint256 public WL_PRICE = 0.1 ether;
    uint256 public PUBLIC_PRICE = 0.2 ether;
    uint256 public FREE_PER_WALLET = 1;
    uint256 public WL_PER_WALLET = 10;
    uint256 public PUBLIC_PER_WALLET = 5;
    uint256 public FREE_START = 2;
    uint256 public FREE_STOP = 4;
    uint256 public WL_START = 4;
    uint256 public WL_STOP = 6;
    uint256 public PUBLIC_START = 7;
    uint256 public PUBLIC_STOP = 9;
    string public BASE_URL = "https://localhost/";
    // THIS VARIBALES CAN BE CHANGED //

    bool public MINT_STOP = false;

    bytes32 public freeMerkleRoot;
    bytes32 public wlMerkleRoot;

    mapping(address => uint256) private freeClaimed;
    mapping(address => uint256) private wlClaimed;
    mapping(address => uint256) private publicClaimed;

    Counters.Counter private _tokenIdCounter;

    // Change this name and symbol
    constructor() ERC721("Token Name2", "TNS2") {}

    // modifier checkZeroAmount(uint256 _amount) {
    //     if (_amount <= 0) {
    //         revert("InvalidAmount");
    //     }
    //     _;
    // }

    // modifier checkMaxSupply(uint256 _amount) {
    //     if ((_tokenIdCounter.current() + _amount) > MAX_SUPPLY) {
    //         revert("OverflowMaxSupply");
    //     }
    //     _;
    // }

    modifier isFreeStart() {
        if (block.timestamp < FREE_START) {
            revert("FreeMintNotStarted"); //@audit-info use custom error for gas saving
        } else if (block.timestamp > FREE_STOP) {
            revert("FreeMintFinished");
        } else if (MINT_STOP) {
            revert("MintingStopped");
        }
        _;
    }

    modifier isWlStart() {
        if (block.timestamp < WL_START) {
            revert("WlMintNotStarted");
        } else if (block.timestamp > WL_STOP) {
            revert("WlMintFinished");
        } else if (MINT_STOP) {
            revert("MintingStopped");
        }
        _;
    }

    modifier isPublicStart() {
        //@audit-issue does not control if the public minting is finished
        if (block.timestamp < PUBLIC_START) {
            revert("PublicMintNotStarted");
        } else if (MINT_STOP) {
            revert("MintingStopped");
        }
        _;
    }

    /**
     * @notice Change freelist merkle root hash.
     * @dev Only the contract owner can change the merkle root hash for the freelist.
     * @param _merkleRootHash New merkle root hash for the freelist.
     */
    function setFreelistRoot(bytes32 _merkleRootHash) external onlyOwner {
        freeMerkleRoot = _merkleRootHash;
    }

    /**
     * @notice Change whitelist merkle root hash.
     * @dev Only the contract owner can change the merkle root hash for the whitelist.
     * @param _merkleRootHash New merkle root hash for the whitelist.
     */
    function setWhitelistRoot(bytes32 _merkleRootHash) external onlyOwner {
        wlMerkleRoot = _merkleRootHash;
    }

    /**
     * @notice Verify freelist merkle proof of the address.
     * @param _merkleProof Merkle proof for the user's address.
     * @return Whether the provided Merkle proof is valid for the freelist.
     */

    function verifyFreelist(bytes32[] calldata _merkleProof) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, freeMerkleRoot, leaf);
    }

    /**
     * @notice Verify whitelist merkle proof of the address.
     * @param _merkleProof Merkle proof for the user's address.
     * @return Whether the provided Merkle proof is valid for the whitelist.
     */
    function verifyWhitelist(bytes32[] calldata _merkleProof) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, wlMerkleRoot, leaf);
    }

    /**
     * @dev Internal function to get the base URI for token metadata.
     * @return Base URI for token metadata.
     */
    function _baseURI() internal view override returns (string memory) {
        return BASE_URL;
    }

    /**
     * @notice Get the URI for a specific token.
     * @dev Returns the metadata URI for a given token ID.
     * @param tokenId ID of the token.
     * @return Token URI.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // @audit-info external -> public
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }

    /**
     * @notice Check if a specific token is minted.
     * @dev Returns true if the token exists (is minted), false otherwise.
     * @param tokenId ID of the token to check.
     * @return A boolean indicating if the token is minted.
     */
    function isMinted(uint256 tokenId) public view returns (bool) {
        // @audit-info external -> public
        if (_exists(tokenId)) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Get the times for different stages.
     * @dev Returns the timestamps for FREE_START, FREE_STOP, WL_START, WL_STOP, PUBLIC_START, and PUBLIC_STOP.
     * @return Six uint256 values representing the timestamps for different stages.
     */
    function getTimes() public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        // @audit-info external -> public
        return (FREE_START, FREE_STOP, WL_START, WL_STOP, PUBLIC_START, PUBLIC_STOP);
    }

    /**
     * @notice Get a list of tokens owned by a specific address.
     * @dev Returns an array containing the token IDs owned by the given address.
     * @param _tokenOwner The address of the token owner.
     * @return An array of uint256 representing the token IDs owned by the given address.
     */
    function getTokenListByOwner(address _tokenOwner) public view returns (uint256[] memory) {
        //@audit-info transferFrom can manipulate index of token
        uint256 totalTokens = balanceOf(_tokenOwner);

        uint256[] memory ownedTokens = new uint256[](totalTokens);
        for (uint256 i = 0; i < totalTokens; i++) {
            ownedTokens[i] = tokenOfOwnerByIndex(_tokenOwner, i);
        }

        return ownedTokens;
    }

    /**
     * @notice Set the base URL for token URIs.
     * @dev Only the contract owner can set the base URL.
     * @param _url The new base URL for token URIs.
     */
    function setBaseUrl(string memory _url) public onlyOwner {
        //@audit-info external -> public
        BASE_URL = _url;
    }

    /**
     * @notice Set the times for different stages.
     * @dev Allows the contract owner to set the timestamps for FREE_START, FREE_STOP, WL_START, WL_STOP, PUBLIC_START, and PUBLIC_STOP.
     * @param _freeStart Timestamp for the start of the free stage.
     * @param _freeStop Timestamp for the end of the free stage.
     * @param _wlStart Timestamp for the start of the whitelist stage.
     * @param _wlStop Timestamp for the end of the whitelist stage.
     * @param _publicStart Timestamp for the start of the public sale stage.
     * @param _publicStop Timestamp for the end of the public sale stage.
     * @dev Throws if the provided times are not valid (e.g., start time is in the past, stop time is before start time).
     * @dev Only the contract owner can call this function.
     */
    function setTimes(
        uint256 _freeStart,
        uint256 _freeStop,
        uint256 _wlStart,
        uint256 _wlStop,
        uint256 _publicStart,
        uint256 _publicStop
    ) public onlyOwner {
        // require(block.timestamp <= _freeStart && _freeStart < _freeStop && _freeStop <= _wlStart, "InvalidFreeMintTime");
        if (block.timestamp > _freeStart || _freeStart >= _freeStop || _freeStop > _wlStart) {
            revert("InvalidFreeMintTime");
        }
        // require(_wlStart < _wlStop && _wlStop <= _publicStart, "InvalidWlTime")
        if (_wlStart >= _wlStop || _wlStop > _publicStart) {
            revert("InvalidWlTime");
        }
        // require(_publicStart < _publicStop, "InvalidPublicTime");
        if (_publicStart >= _publicStop) {
            revert("InvalidPublicTime");
        }

        FREE_START = _freeStart;
        FREE_STOP = _freeStop;
        WL_START = _wlStart;
        WL_STOP = _wlStop;
        PUBLIC_START = _publicStart;
        PUBLIC_STOP = _publicStop;
    }

    /**
     * @notice Enable mint stop.
     * @dev Only the contract owner can enable mint stop.
     * When mint stop is enabled, no new tokens can be minted.
     */
    function setMintStop(bool _status) public onlyOwner {
        //@audit-info naming: setMintStop -> setMintStatus
        MINT_STOP = _status;
    }

    /**
     * @notice Mint tokens by the owner.
     * @dev Only the contract owner can mint tokens using this function.
     * @param _qty Number of tokens to mint.
     */
    function ownerMint(uint256 _qty) public onlyOwner nonReentrant {
        //@audit-info does not need to control negative inputs, only zero amount
        if (_qty <= 0) {
            revert("InvalidQuantity");
        }
        if ((_tokenIdCounter.current() + _qty) > MAX_SUPPLY) {
            revert("OverflowMaxSupply");
        }

        for (uint256 i = 0; i < _qty; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }
    }

    /**
     * @notice Freelist minting function.
     * @dev This function allows eligible users to claim free tokens as part of a special promotion.
     * Users must provide a valid Merkle proof to show they are included in the freelist.
     * The minting can only be done during the specified freelist period.
     * @param _merkleProof Merkle proof for the user's address.
     * @param _qty Number of tokens to mint.
     */
    // eoa - contract interaction
    function freeMint(bytes32[] calldata _merkleProof, uint256 _qty) public isFreeStart nonReentrant {
        if (_qty <= 0) {
            revert("InvalidQuantity");
        }
        if ((_tokenIdCounter.current() + _qty) > MAX_SUPPLY) {
            //@audit-info If the free_per_wallet check is earlier, the contract will consume less gas
            revert("OverflowMaxSupply");
        }
        if (!verifyFreelist(_merkleProof)) {
            //@audit-info verifyFreelist check must be earlier
            revert("HaveNotEligible");
        }
        // require((freeClaimed[msg.sender] + _qty) <= FREE_PER_WALLET, "FreeMintLimitExceeded"
        if ((freeClaimed[msg.sender] + _qty) > FREE_PER_WALLET) {
            //@audit-info naming: "FreeMintLimitExceeded"
            revert("OverflowQuantity");
        }

        for (uint256 i = 0; i < _qty; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            freeClaimed[msg.sender] = freeClaimed[msg.sender] + 1;
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }

        emit eventFreeMint(msg.sender, _qty);
    }

    /**
     * @notice Whitelist minting function.
     * @dev This function allows eligible users to mint tokens by sending ETH.
     * Users must provide a valid Merkle proof to show they are included in the whitelist.
     * The minting can only be done during the specified whitelist period.
     * @param _merkleProof Merkle proof for the user's address.
     * @param _qty Number of tokens to mint.
     */
    function wlMint(bytes32[] calldata _merkleProof, uint256 _qty) public payable isWlStart nonReentrant {
        if (_qty <= 0) {
            revert("InvalidQuantity");
        }
        if ((_tokenIdCounter.current() + _qty) > MAX_SUPPLY) {
            revert("OverflowMaxSupply");
        }
        if (!verifyWhitelist(_merkleProof)) {
            revert("HaveNotEligible");
        }
        if ((wlClaimed[msg.sender] + _qty) > WL_PER_WALLET) {
            revert("OverflowQuantity");
        }
        if (msg.value != (_qty * WL_PRICE)) {
            revert("InsufficientBalance");
        }

        for (uint256 i = 0; i < _qty; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            wlClaimed[msg.sender] = wlClaimed[msg.sender] + 1;
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }

        emit eventWlMint(msg.sender, _qty);
    }

    /**
     * @notice Public minting function.
     * @dev This function allows anyone to mint tokens by sending ETH.
     * The minting can only be done during the specified public minting period.
     * @param _qty Number of tokens to mint.
     */
    function publicMint(uint256 _qty) public payable isPublicStart nonReentrant {
        if (_qty <= 0) {
            revert("InvalidQuantity");
        }
        if ((_tokenIdCounter.current() + _qty) > MAX_SUPPLY) {
            revert("OverflowMaxSupply");
        }
        if ((publicClaimed[msg.sender] + _qty) > PUBLIC_PER_WALLET) {
            revert("OverflowQuantity");
        }
        if (msg.value != (_qty * PUBLIC_PRICE)) {
            revert("InsufficientBalance");
        }

        for (uint256 i = 0; i < _qty; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            publicClaimed[msg.sender] = publicClaimed[msg.sender] + 1;
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        }

        emit eventPublicMint(msg.sender, _qty);
    }

    /**
     * @notice Transfer multiple tokens to a specified address.
     * @dev Transfers multiple tokens from the sender's address to the specified address.
     * @param _to The address to which the tokens will be transferred.
     * @param _tokenIds An array containing the token IDs to be transferred.
     */
    function multipleTransfer(address _to, uint256[] memory _tokenIds) public nonReentrant {
        if (_to == address(0) || _to == msg.sender) {
            revert("InvalidAddress");
        }
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _requireMinted(_tokenIds[i]);
            if (ownerOf(_tokenIds[i]) != msg.sender) {
                revert("YouNotTokenHolder");
            }
        }

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _transfer(msg.sender, _to, _tokenIds[i]);
        }
    }

    /**
     * @notice Withdraw the contract balance to the contract owner.
     * @dev Only the contract owner can withdraw the contract balance to their address.
     */
    function withdrawMoney() public onlyOwner {
        uint256 amount = address(this).balance;
        address projectOwner = owner();

        (bool success, bytes memory data) = projectOwner.call{value: amount}("");
        if (!success) {
            revert("WithdrawalFailed");
        }

        emit eventWithdraw(projectOwner, amount, data);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    event eventFreeMint(address indexed _to, uint256 _qty);
    event eventWlMint(address indexed _to, uint256 _qty);
    event eventPublicMint(address indexed _to, uint256 _qty);
    event eventWithdraw(address indexed _to, uint256 _amount, bytes _data);

    //--. --- .-. -.- . -- / -.-- .- ...- ..- --..
}

//@audit-info layout
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions
