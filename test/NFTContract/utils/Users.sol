// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

struct Users {
    address payable owner;
    address payable freeMinter;
    address payable whitelistMinter;
    address payable publicMinter;
    address payable guest;
}
