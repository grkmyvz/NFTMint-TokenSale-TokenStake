// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    constructor() ERC20("Test Token", "TT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}
