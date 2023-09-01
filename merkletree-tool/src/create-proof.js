const fs = require("fs");
const path = require("path");
const { ethers } = require("ethers");
const { MerkleTree } = require("merkletreejs");

const nftFreelist = require("./nft-freelist.json");
const nftWhitelist = require("./nft-whitelist.json");
const outDirectory = "./out";

const keccak256 = ethers.keccak256;

let nftFreelistOut = [];
let nftWhitelistOut = [];

function forNFTFreelist() {
  const leafNodes = nftFreelist.map((addr) =>
    keccak256(Buffer.concat([Buffer.from(addr.replace("0x", ""), "hex")]))
  );

  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

  for (let i = 0; i < nftFreelist.length; i++) {
    nftFreelistOut.push({
      address: nftFreelist[i],
      proof: merkleTree.getHexProof(leafNodes[i]),
    });
  }
  fs.writeFileSync(
    path.join(outDirectory, `nft-freelist-proofs.json`),
    JSON.stringify({
      merkleRoot: merkleTree.getHexRoot(),
      proofs: nftFreelistOut,
    })
  );
}

function forNFTWhitelist() {
  const leafNodes = nftWhitelist.map((addr) =>
    keccak256(Buffer.concat([Buffer.from(addr.replace("0x", ""), "hex")]))
  );

  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

  for (let i = 0; i < nftWhitelist.length; i++) {
    nftWhitelistOut.push({
      address: nftWhitelist[i],
      proof: merkleTree.getHexProof(leafNodes[i]),
    });
  }
  fs.writeFileSync(
    path.join(outDirectory, `nft-whitelist-proofs.json`),
    JSON.stringify({
      merkleRoot: merkleTree.getHexRoot(),
      proofs: nftWhitelistOut,
    })
  );
}

try {
  forNFTFreelist();
  forNFTWhitelist();

  console.log("Done!");
} catch (e) {
  console.log(e);
}
