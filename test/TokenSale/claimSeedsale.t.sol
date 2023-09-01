// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract claimSeedsale is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event SeedsaleClaimed(address indexed _to, uint256 _amount);

    function buyedSeedsaleTokens()
        public
        sendTokens
        activeSeedsaleRoot
        startedSeedsale
    {
        bytes32[] memory seedsaleMinter1Proof = new bytes32[](2);
        seedsaleMinter1Proof[0] = bytes32(
            0xf9ff3bcd5ae7b826e9d51586d3a61d5edc6b8a8a5916c90b44b4172d4082fda9
        );

        seedsaleMinter1Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );

        uint256 amount = tokenSale.SEEDSALE_MAX_PER_WALLET();
        uint256 price = tokenSale.SEEDSALE_PRICE();
        vm.prank(users.seedsaleBuyer1);
        tokenSale.buySeedsale{value: amount * price}(
            seedsaleMinter1Proof,
            amount
        );
    }

    function test_ShouldBeSuccess_claimSeedsale() public {
        buyedSeedsaleTokens();
        uint256 beforeContractTokenBalance = testToken.balanceOf(
            address(tokenSale)
        );
        uint256 amount = (tokenSale.seedsaleBalances(
            address(users.seedsaleBuyer1)
        ) / tokenSale.SEEDSALE_CLAIM_PERIOD()) * 10 ** 18;

        for (uint256 i = 1; i <= tokenSale.SEEDSALE_CLAIM_PERIOD(); i++) {
            vm.warp(
                tokenSale.SEEDSALE_CLAIM_START_TIME() +
                    (tokenSale.PERIOD_TIME() * i)
            );
            if (i == tokenSale.SEEDSALE_CLAIM_PERIOD()) {
                amount =
                    tokenSale.seedsaleBalances(address(users.seedsaleBuyer1)) *
                    10 ** 18;
            }
            vm.prank(users.seedsaleBuyer1);
            vm.expectEmit(address(tokenSale));
            emit SeedsaleClaimed(address(users.seedsaleBuyer1), amount);
            tokenSale.claimSeedsale(i);

            if (i == tokenSale.SEEDSALE_CLAIM_PERIOD()) {
                assertEq(
                    tokenSale.seedsaleBalances(address(users.seedsaleBuyer1)),
                    0
                );
                assertEq(
                    testToken.balanceOf(address(users.seedsaleBuyer1)),
                    tokenSale.SEEDSALE_MAX_PER_WALLET() * 10 ** 18
                );
                assertEq(
                    testToken.balanceOf(address(tokenSale)),
                    beforeContractTokenBalance -
                        tokenSale.SEEDSALE_MAX_PER_WALLET() *
                        10 ** 18
                );
            } else {
                assertEq(
                    testToken.balanceOf(address(users.seedsaleBuyer1)),
                    amount * i
                );
                assertEq(
                    testToken.balanceOf(address(tokenSale)),
                    beforeContractTokenBalance - (amount * i)
                );
            }
        }
    }

    function test_Revert_InvalidPeriod_claimSeedsale() public {
        buyedSeedsaleTokens();
        vm.warp(
            tokenSale.SEEDSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME()
        );
        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidPeriod.selector);
        tokenSale.claimSeedsale(0);

        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidPeriod.selector);
        tokenSale.claimSeedsale(6);
    }

    function test_Revert_SeedsaleClaimPeriodNotStarted_claimSeedsale() public {
        buyedSeedsaleTokens();
        vm.warp(tokenSale.SEEDSALE_CLAIM_START_TIME());
        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.SeedsaleClaimPeriodNotStarted.selector);
        tokenSale.claimSeedsale(1);
    }

    function test_Revert_ZeroBalance_claimSeedsale() public {
        buyedSeedsaleTokens();
        vm.warp(
            tokenSale.SEEDSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME()
        );
        vm.prank(users.seedsaleBuyer2);
        vm.expectRevert(TokenSale.ZeroBalance.selector);
        tokenSale.claimSeedsale(1);
    }

    function test_Revert_BeforeClaimFirstPeriod_claimSeedsale() public {
        buyedSeedsaleTokens();
        vm.warp(
            tokenSale.SEEDSALE_CLAIM_START_TIME() +
                (tokenSale.PERIOD_TIME() * 2)
        );
        vm.prank(users.seedsaleBuyer1);
        vm.expectRevert(TokenSale.BeforeClaimFirstPeriod.selector);
        tokenSale.claimSeedsale(2);
    }

    function test_Revert_SeedsaleAlreadyClaimed_claimSeedsale() public {
        buyedSeedsaleTokens();
        vm.warp(
            tokenSale.SEEDSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME()
        );
        vm.startPrank(users.seedsaleBuyer1);
        tokenSale.claimSeedsale(1);
        vm.expectRevert(TokenSale.SeedsaleAlreadyClaimed.selector);
        tokenSale.claimSeedsale(1);
        vm.stopPrank();
    }
}
