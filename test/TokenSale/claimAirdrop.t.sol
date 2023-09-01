// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../src/TokenSale.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract claimAirdrop is BaseSetup {
    // Defined in TokenSale.sol (If you change it, you need to change it here too)
    event AirdropClaimed(address indexed _to, uint256 _amount);

    function buyedAirdropTokens()
        public
        sendTokens
        activeAirdropRoot
        startedAirdrop
    {
        bytes32[] memory airdropMinter1Proof = new bytes32[](2);
        airdropMinter1Proof[0] = bytes32(
            0x8fcf3db81ddc9cee33449c63bc0db165bf61739ce0de36128f1e07c3f7f7b270
        );

        airdropMinter1Proof[1] = bytes32(
            0x2fa0b85315835788c20e90a54c4b0d74a53b0f06be6bc835b57fa2b44daf17c2
        );

        vm.prank(users.airdropBuyer1);
        tokenSale.buyAirdrop(airdropMinter1Proof);
    }

    function test_ShouldBeSuccess_claimAirdrop() public {
        buyedAirdropTokens();
        uint256 beforeContractTokenBalance = testToken.balanceOf(
            address(tokenSale)
        );
        uint256 amount = (tokenSale.airdropBalances(
            address(users.airdropBuyer1)
        ) / tokenSale.AIRDROP_CLAIM_PERIOD()) * 10 ** 18;

        for (uint256 i = 1; i <= tokenSale.AIRDROP_CLAIM_PERIOD(); i++) {
            vm.warp(
                tokenSale.AIRDROP_CLAIM_START_TIME() +
                    (tokenSale.PERIOD_TIME() * i)
            );
            if (i == tokenSale.AIRDROP_CLAIM_PERIOD()) {
                amount =
                    tokenSale.airdropBalances(address(users.airdropBuyer1)) *
                    10 ** 18;
            }
            vm.prank(users.airdropBuyer1);
            vm.expectEmit(address(tokenSale));
            emit AirdropClaimed(address(users.airdropBuyer1), amount);
            tokenSale.claimAirdrop(i);

            if (i == tokenSale.AIRDROP_CLAIM_PERIOD()) {
                assertEq(
                    tokenSale.airdropBalances(address(users.airdropBuyer1)),
                    0
                );
                assertEq(
                    testToken.balanceOf(address(users.airdropBuyer1)),
                    tokenSale.AIRDROP_MAX_PER_WALLET() * 10 ** 18
                );
                assertEq(
                    testToken.balanceOf(address(tokenSale)),
                    beforeContractTokenBalance -
                        tokenSale.AIRDROP_MAX_PER_WALLET() *
                        10 ** 18
                );
            } else {
                assertEq(
                    testToken.balanceOf(address(users.airdropBuyer1)),
                    amount * i
                );
                assertEq(
                    testToken.balanceOf(address(tokenSale)),
                    beforeContractTokenBalance - (amount * i)
                );
            }
        }
    }

    function test_Revert_InvalidPeriod_claimAirdrop() public {
        buyedAirdropTokens();
        vm.warp(tokenSale.AIRDROP_CLAIM_START_TIME() + tokenSale.PERIOD_TIME());
        vm.prank(users.airdropBuyer1);
        vm.expectRevert(TokenSale.InvalidPeriod.selector);
        tokenSale.claimAirdrop(0);

        vm.prank(users.airdropBuyer1);
        vm.expectRevert(TokenSale.InvalidPeriod.selector);
        tokenSale.claimAirdrop(6);
    }

    function test_Revert_AirdropClaimPeriodNotStarted_claimAirdrop() public {
        buyedAirdropTokens();
        vm.warp(tokenSale.AIRDROP_CLAIM_START_TIME());
        vm.prank(users.airdropBuyer1);
        vm.expectRevert(TokenSale.AirdropClaimPeriodNotStarted.selector);
        tokenSale.claimAirdrop(1);
    }

    function test_Revert_ZeroBalance_claimAirdrop() public {
        buyedAirdropTokens();
        vm.warp(tokenSale.AIRDROP_CLAIM_START_TIME() + tokenSale.PERIOD_TIME());
        vm.prank(users.airdropBuyer2);
        vm.expectRevert(TokenSale.ZeroBalance.selector);
        tokenSale.claimAirdrop(1);
    }

    function test_Revert_BeforeClaimFirstPeriod_claimAirdrop() public {
        buyedAirdropTokens();
        vm.warp(
            tokenSale.AIRDROP_CLAIM_START_TIME() + (tokenSale.PERIOD_TIME() * 2)
        );
        vm.prank(users.airdropBuyer1);
        vm.expectRevert(TokenSale.BeforeClaimFirstPeriod.selector);
        tokenSale.claimAirdrop(2);
    }

    function test_Revert_AirdropAlreadyClaimed_claimAirdrop() public {
        buyedAirdropTokens();
        vm.warp(tokenSale.AIRDROP_CLAIM_START_TIME() + tokenSale.PERIOD_TIME());
        vm.startPrank(users.airdropBuyer1);
        tokenSale.claimAirdrop(1);
        vm.expectRevert(TokenSale.AirdropAlreadyClaimed.selector);
        tokenSale.claimAirdrop(1);
        vm.stopPrank();
    }
}
