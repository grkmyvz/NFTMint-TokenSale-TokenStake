// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "../src/TokenSale.sol";

contract TokenSaleScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Write your ERC20 token address here
        new TokenSale(0x0000000000000000000000000000000000000000);

        vm.stopBroadcast();
    }
}
