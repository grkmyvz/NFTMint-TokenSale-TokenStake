// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {BaseSetup} from "./NFTContract/BaseSetup.t.sol";
import {Variables} from "./NFTContract/Variables.t.sol";
import {Constructor} from "./NFTContract/Constructor.t.sol";
import {tokenURI} from "./NFTContract/tokenURI.t.sol";
import {isMinted} from "./NFTContract/isMinted.t.sol";
import {getTokenListByOwner} from "./NFTContract/getTokenListByOwner.t.sol";
import {setFreelistRoot} from "./NFTContract/setFreelistRoot.t.sol";
import {setWhitelistRoot} from "./NFTContract/setWhitelistRoot.t.sol";
import {setBaseUrl} from "./NFTContract/setBaseUrl.t.sol";
import {setPrices} from "./NFTContract/setPrices.t.sol";
import {ownerMint} from "./NFTContract/ownerMint.t.sol";
import {withdrawMoney} from "./NFTContract/withdrawMoney.t.sol";
import {freeMint} from "./NFTContract/freeMint.t.sol";
import {whitelistMint} from "./NFTContract/whitelistMint.t.sol";
import {publicMint} from "./NFTContract/publicMint.t.sol";
import {multipleTransfer} from "./NFTContract/multipleTransfer.t.sol";

contract NFTContractAudit is
    BaseSetup,
    Variables,
    Constructor,
    tokenURI,
    isMinted,
    getTokenListByOwner,
    setFreelistRoot,
    setWhitelistRoot,
    setBaseUrl,
    setPrices,
    ownerMint,
    withdrawMoney,
    freeMint,
    whitelistMint,
    publicMint,
    multipleTransfer
{}
