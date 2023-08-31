// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract claimPublicsale is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event PublicsaleClaimed(address indexed _to, uint256 _amount);

    function buyedPublicsaleTokens() public sendTokens startedPublicsale {
        bytes32[] memory publicsaleMinter1Proof = new bytes32[](2);
        publicsaleMinter1Proof[0] = bytes32(
            0x3e166e3b353fca9c2d646d7ad8f49e4208eaffbc97b118375228935a388df3fa
        );

        publicsaleMinter1Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );

        uint256 amount = tokenSale.PUBLICSALE_MAX_PER_WALLET();
        uint256 price = tokenSale.PUBLICSALE_PRICE();
        vm.prank(users.publicsaleBuyer1);
        tokenSale.buyPublicsale{value: amount * price}(amount);
    }

    function test_ShouldBeSuccess_claimPublicsale() public {
        buyedPublicsaleTokens();
        uint256 beforeContractTokenBalance = testToken.balanceOf(
            address(tokenSale)
        );
        uint256 amount = (tokenSale.publicsaleBalances(
            address(users.publicsaleBuyer1)
        ) / tokenSale.PUBLICSALE_CLAIM_PERIOD()) * 10 ** 18;

        for (uint256 i = 1; i <= tokenSale.PUBLICSALE_CLAIM_PERIOD(); i++) {
            vm.warp(
                tokenSale.PUBLICSALE_CLAIM_START_TIME() +
                    (tokenSale.PERIOD_TIME() * i)
            );
            if (i == tokenSale.PUBLICSALE_CLAIM_PERIOD()) {
                amount =
                    tokenSale.publicsaleBalances(
                        address(users.publicsaleBuyer1)
                    ) *
                    10 ** 18;
            }
            vm.prank(users.publicsaleBuyer1);
            vm.expectEmit(address(tokenSale));
            emit PublicsaleClaimed(address(users.publicsaleBuyer1), amount);
            tokenSale.claimPublicsale(i);

            if (i == tokenSale.PUBLICSALE_CLAIM_PERIOD()) {
                assertEq(
                    tokenSale.publicsaleBalances(
                        address(users.publicsaleBuyer1)
                    ),
                    0
                );
                assertEq(
                    testToken.balanceOf(address(users.publicsaleBuyer1)),
                    tokenSale.PUBLICSALE_MAX_PER_WALLET() * 10 ** 18
                );
                assertEq(
                    testToken.balanceOf(address(tokenSale)),
                    beforeContractTokenBalance -
                        tokenSale.PUBLICSALE_MAX_PER_WALLET() *
                        10 ** 18
                );
            } else {
                assertEq(
                    testToken.balanceOf(address(users.publicsaleBuyer1)),
                    amount * i
                );
                assertEq(
                    testToken.balanceOf(address(tokenSale)),
                    beforeContractTokenBalance - (amount * i)
                );
            }
        }
    }

    function test_Revert_InvalidPeriod_claimPublicsale() public {
        buyedPublicsaleTokens();
        vm.warp(
            tokenSale.PUBLICSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME()
        );
        vm.prank(users.publicsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidPeriod.selector);
        tokenSale.claimPublicsale(0);

        vm.prank(users.publicsaleBuyer1);
        vm.expectRevert(TokenSale.InvalidPeriod.selector);
        tokenSale.claimPublicsale(6);
    }

    function test_Revert_PublicsaleClaimPeriodNotStarted_claimPublicsale()
        public
    {
        buyedPublicsaleTokens();
        vm.warp(tokenSale.PUBLICSALE_CLAIM_START_TIME());
        vm.prank(users.publicsaleBuyer1);
        vm.expectRevert(TokenSale.PublicsaleClaimPeriodNotStarted.selector);
        tokenSale.claimPublicsale(1);
    }

    function test_Revert_ZeroBalance_claimPublicsale() public {
        buyedPublicsaleTokens();
        vm.warp(
            tokenSale.PUBLICSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME()
        );
        vm.prank(users.publicsaleBuyer2);
        vm.expectRevert(TokenSale.ZeroBalance.selector);
        tokenSale.claimPublicsale(1);
    }

    function test_Revert_BeforeClaimFirstPeriod_claimPublicsale() public {
        buyedPublicsaleTokens();
        vm.warp(
            tokenSale.PUBLICSALE_CLAIM_START_TIME() +
                (tokenSale.PERIOD_TIME() * 2)
        );
        vm.prank(users.publicsaleBuyer1);
        vm.expectRevert(TokenSale.BeforeClaimFirstPeriod.selector);
        tokenSale.claimPublicsale(2);
    }

    function test_Revert_PublicsaleAlreadyClaimed_claimPublicsale() public {
        buyedPublicsaleTokens();
        vm.warp(
            tokenSale.PUBLICSALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME()
        );
        vm.startPrank(users.publicsaleBuyer1);
        tokenSale.claimPublicsale(1);
        vm.expectRevert(TokenSale.PublicsaleAlreadyClaimed.selector);
        tokenSale.claimPublicsale(1);
        vm.stopPrank();
    }
}
