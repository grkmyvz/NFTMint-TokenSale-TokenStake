const fs = require("fs");
const path = require("path");
const { ethers } = require("ethers");
const { MerkleTree } = require("merkletreejs");

const nftFreelist = require("./nft-freelist.json");
const nftWhitelist = require("./nft-whitelist.json");
const tokenFreelist = require("./token-freelist.json");
const tokenSeedlist = require("./token-seedlist.json");
const tokenPrelist = require("./token-prelist.json");
const outDirectory = "./out";

const keccak256 = ethers.keccak256;

let nftFreelistOut = [];
let nftWhitelistOut = [];
let tokenFreelistOut = [];
let tokenSeedlistOut = [];
let tokenPrelistOut = [];

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

function forTokenFreelist() {
  const leafNodes = tokenFreelist.map((addr) =>
    keccak256(Buffer.concat([Buffer.from(addr.replace("0x", ""), "hex")]))
  );

  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

  for (let i = 0; i < tokenFreelist.length; i++) {
    tokenFreelistOut.push({
      address: tokenFreelist[i],
      proof: merkleTree.getHexProof(leafNodes[i]),
    });
  }
  fs.writeFileSync(
    path.join(outDirectory, `token-freelist-proofs.json`),
    JSON.stringify({
      merkleRoot: merkleTree.getHexRoot(),
      proofs: tokenFreelistOut,
    })
  );
}

function forTokenSeedlist() {
  const leafNodes = tokenSeedlist.map((addr) =>
    keccak256(Buffer.concat([Buffer.from(addr.replace("0x", ""), "hex")]))
  );

  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

  for (let i = 0; i < tokenSeedlist.length; i++) {
    tokenSeedlistOut.push({
      address: tokenSeedlist[i],
      proof: merkleTree.getHexProof(leafNodes[i]),
    });
  }
  fs.writeFileSync(
    path.join(outDirectory, `token-seedlist-proofs.json`),
    JSON.stringify({
      merkleRoot: merkleTree.getHexRoot(),
      proofs: tokenSeedlistOut,
    })
  );
}

function forTokenPrelist() {
  const leafNodes = tokenPrelist.map((addr) =>
    keccak256(Buffer.concat([Buffer.from(addr.replace("0x", ""), "hex")]))
  );

  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

  for (let i = 0; i < tokenPrelist.length; i++) {
    tokenPrelistOut.push({
      address: tokenPrelist[i],
      proof: merkleTree.getHexProof(leafNodes[i]),
    });
  }
  fs.writeFileSync(
    path.join(outDirectory, `token-prelist-proofs.json`),
    JSON.stringify({
      merkleRoot: merkleTree.getHexRoot(),
      proofs: tokenPrelistOut,
    })
  );
}

try {
  forNFTFreelist();
  forNFTWhitelist();
  forTokenFreelist();
  forTokenSeedlist();
  forTokenPrelist();

  console.log("Done!");
} catch (e) {
  console.log(e);
}
