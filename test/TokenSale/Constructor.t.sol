// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract Constructor is BaseSetup {
    TokenSale public deployedTokenSale;

    function test_ShouldBeDeploy() public {
        deployedTokenSale = new TokenSale(address(testToken));

        assertTrue(address(deployedTokenSale) != address(0));
        assertEq(address(deployedTokenSale.token()), address(testToken));
    }

    function test_Revert_InvalidTokenAddress_constructor() public {
        vm.expectRevert(TokenSale.InvalidTokenAddress.selector);
        deployedTokenSale = new TokenSale(address(0));
    }
}
