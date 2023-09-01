// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./TokenSale/BaseSetup.t.sol";
import {Variables} from "./TokenSale/Variables.t.sol";
import {Constructor} from "./TokenSale/Constructor.t.sol";
import {setSendTokens} from "./TokenSale/setSendTokens.t.sol";
import {setAirdropMerkleRoot} from "./TokenSale/setAirdropMerkleRoot.t.sol";
import {setSeedsaleMerkleRoot} from "./TokenSale/setSeedsaleMerkleRoot.t.sol";
import {setPresaleMerkleRoot} from "./TokenSale/setPresaleMerkleRoot.t.sol";
import {setAirdropStatus} from "./TokenSale/setAirdropStatus.t.sol";
import {setSeedsaleStatus} from "./TokenSale/setSeedsaleStatus.t.sol";
import {setPresaleStatus} from "./TokenSale/setPresaleStatus.t.sol";
import {setPublicsaleStatus} from "./TokenSale/setPublicsaleStatus.t.sol";
import {withdrawCoin} from "./TokenSale/withdrawCoin.t.sol";
import {withdrawToken} from "./TokenSale/withdrawToken.t.sol";
import {buyAirdrop} from "./TokenSale/buyAirdrop.t.sol";
import {buySeedsale} from "./TokenSale/buySeedsale.t.sol";
import {buyPresale} from "./TokenSale/buyPresale.t.sol";
import {buyPublicsale} from "./TokenSale/buyPublicsale.t.sol";
import {claimAirdrop} from "./TokenSale/claimAirdrop.t.sol";
import {claimSeedsale} from "./TokenSale/claimSeedsale.t.sol";
import {claimPresale} from "./TokenSale/claimPresale.t.sol";
import {claimPublicsale} from "./TokenSale/claimPublicsale.t.sol";

contract TokenSaleAudit is
    BaseSetup,
    Variables,
    Constructor,
    setSendTokens,
    setAirdropMerkleRoot,
    setSeedsaleMerkleRoot,
    setPresaleMerkleRoot,
    setAirdropStatus,
    setSeedsaleStatus,
    setPresaleStatus,
    setPublicsaleStatus,
    withdrawCoin,
    withdrawToken,
    buyAirdrop,
    buySeedsale,
    buyPresale,
    buyPublicsale,
    claimAirdrop,
    claimSeedsale,
    claimPresale,
    claimPublicsale
{}
