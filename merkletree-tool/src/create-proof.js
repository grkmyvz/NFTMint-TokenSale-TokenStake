const fs = require("fs");
const path = require("path");
const { ethers } = require("ethers");
const { MerkleTree } = require("merkletreejs");

// THIS VARIABLES CAN BE CHANGED
const walletList = require("./wl-list1.json");
const outDirectory = "./out";
const outFileName = "proofs";
// THIS VARIABLES CAN BE CHANGED

const keccak256 = ethers.keccak256;

const leafNodes = walletList.map((addr) =>
  keccak256(Buffer.concat([Buffer.from(addr.replace("0x", ""), "hex")]))
);

const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

let out = [];

for (let i = 0; i < walletList.length; i++) {
  out.push({
    address: walletList[i],
    proof: merkleTree.getHexProof(leafNodes[i]),
  });
}

function generateUniqueFileName(directory, baseFileName) {
  let count = 0;
  let fileName = baseFileName;

  while (fs.existsSync(path.join(directory, `${fileName}.json`))) {
    count++;
    fileName = `${baseFileName}${count}`;
  }

  return fileName;
}

try {
  if (!fs.existsSync(outDirectory)) {
    fs.mkdirSync(outDirectory);
  }

  const uniqueFileName = generateUniqueFileName(outDirectory, outFileName);
  fs.writeFileSync(
    path.join(outDirectory, `${uniqueFileName}.json`),
    JSON.stringify({
      merkleRoot: merkleTree.getHexRoot(),
      proofs: out,
    })
  );

  console.log("Merke Hash:", merkleTree.getHexRoot());
  console.log(`Proofs file is saved as "${uniqueFileName}.json".`);
} catch (err) {
  console.error(err);
}
