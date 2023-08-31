// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract claimPresale is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event PresaleClaimed(address indexed _to, uint256 _amount);

    function buyedPresaleTokens()
        public
        sendTokens
        activePresaleRoot
        startedPresale
    {
        bytes32[] memory presaleMinter1Proof = new bytes32[](2);
        presaleMinter1Proof[0] = bytes32(
            0x3e166e3b353fca9c2d646d7ad8f49e4208eaffbc97b118375228935a388df3fa
        );

        presaleMinter1Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );

        uint256 amount = tokenSale.PRESALE_MAX_PER_WALLET();
        uint256 price = tokenSale.PRESALE_PRICE();
        vm.prank(users.presaleBuyer1);
        tokenSale.buyPresale{value: amount * price}(
            presaleMinter1Proof,
            amount
        );
    }

    function test_ShouldBeSuccess_claimPresale() public {
        buyedPresaleTokens();
        uint256 beforeContractTokenBalance = testToken.balanceOf(
            address(tokenSale)
        );
        uint256 amount = (tokenSale.presaleBalances(
            address(users.presaleBuyer1)
        ) / tokenSale.PRESALE_CLAIM_PERIOD()) * 10 ** 18;

        for (uint256 i = 1; i <= tokenSale.PRESALE_CLAIM_PERIOD(); i++) {
            vm.warp(
                tokenSale.PRESALE_CLAIM_START_TIME() +
                    (tokenSale.PERIOD_TIME() * i)
            );
            if (i == tokenSale.PRESALE_CLAIM_PERIOD()) {
                amount =
                    tokenSale.presaleBalances(address(users.presaleBuyer1)) *
                    10 ** 18;
            }
            vm.prank(users.presaleBuyer1);
            vm.expectEmit(address(tokenSale));
            emit PresaleClaimed(address(users.presaleBuyer1), amount);
            tokenSale.claimPresale(i);

            if (i == tokenSale.PRESALE_CLAIM_PERIOD()) {
                assertEq(
                    tokenSale.presaleBalances(address(users.presaleBuyer1)),
                    0
                );
                assertEq(
                    testToken.balanceOf(address(users.presaleBuyer1)),
                    tokenSale.PRESALE_MAX_PER_WALLET() * 10 ** 18
                );
                assertEq(
                    testToken.balanceOf(address(tokenSale)),
                    beforeContractTokenBalance -
                        tokenSale.PRESALE_MAX_PER_WALLET() *
                        10 ** 18
                );
            } else {
                assertEq(
                    testToken.balanceOf(address(users.presaleBuyer1)),
                    amount * i
                );
                assertEq(
                    testToken.balanceOf(address(tokenSale)),
                    beforeContractTokenBalance - (amount * i)
                );
            }
        }
    }

    function test_Revert_InvalidPeriod_claimPresale() public {
        buyedPresaleTokens();
        vm.warp(tokenSale.PRESALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME());
        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.InvalidPeriod.selector);
        tokenSale.claimPresale(0);

        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.InvalidPeriod.selector);
        tokenSale.claimPresale(6);
    }

    function test_Revert_PresaleClaimPeriodNotStarted_claimPresale() public {
        buyedPresaleTokens();
        vm.warp(tokenSale.PRESALE_CLAIM_START_TIME());
        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.PresaleClaimPeriodNotStarted.selector);
        tokenSale.claimPresale(1);
    }

    function test_Revert_ZeroBalance_claimPresale() public {
        buyedPresaleTokens();
        vm.warp(tokenSale.PRESALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME());
        vm.prank(users.presaleBuyer2);
        vm.expectRevert(TokenSale.ZeroBalance.selector);
        tokenSale.claimPresale(1);
    }

    function test_Revert_BeforeClaimFirstPeriod_claimPresale() public {
        buyedPresaleTokens();
        vm.warp(
            tokenSale.PRESALE_CLAIM_START_TIME() + (tokenSale.PERIOD_TIME() * 2)
        );
        vm.prank(users.presaleBuyer1);
        vm.expectRevert(TokenSale.BeforeClaimFirstPeriod.selector);
        tokenSale.claimPresale(2);
    }

    function test_Revert_PresaleAlreadyClaimed_claimPresale() public {
        buyedPresaleTokens();
        vm.warp(tokenSale.PRESALE_CLAIM_START_TIME() + tokenSale.PERIOD_TIME());
        vm.startPrank(users.presaleBuyer1);
        tokenSale.claimPresale(1);
        vm.expectRevert(TokenSale.PresaleAlreadyClaimed.selector);
        tokenSale.claimPresale(1);
        vm.stopPrank();
    }
}
