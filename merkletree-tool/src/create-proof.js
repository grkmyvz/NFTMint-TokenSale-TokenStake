const fs = require("fs").promises;
const path = require("path");
const { ethers } = require("ethers");
const { MerkleTree } = require("merkletreejs");

const inputFiles = [
  "./nft-freelist.json",
  "./nft-whitelist.json",
  "./token-airdroplist.json",
  "./token-seedlist.json",
  "./token-prelist.json",
];

const outDirectory = "./out";

async function checkFilesExistence(files) {
  for (const file of files) {
    try {
      await fs.access(file);
    } catch (e) {
      console.error(`${file} does not exist.`);
      process.exit(1);
    }
  }
}

async function readJsonFile(filePath) {
  const content = await fs.readFile(filePath, "utf-8");
  return JSON.parse(content);
}

async function generateProofs(list, fileName) {
  const leafNodes = list.map((addr) =>
    ethers.utils.keccak256(
      Buffer.concat([Buffer.from(addr.replace("0x", ""), "hex")])
    )
  );
  const merkleTree = new MerkleTree(leafNodes, ethers.utils.keccak256, {
    sortPairs: true,
  });

  const proofsOut = list.map((address, index) => ({
    address,
    proof: merkleTree.getHexProof(leafNodes[index]),
  }));

  await fs.writeFile(
    path.join(outDirectory, fileName),
    JSON.stringify({
      merkleRoot: merkleTree.getHexRoot(),
      proofs: proofsOut,
    })
  );

  console.log(`${fileName} has been written.`);
}

async function main() {
  await checkFilesExistence([...inputFiles, outDirectory]);

  if (!(await fs.stat(outDirectory).catch(() => fs.mkdir(outDirectory)))) {
    console.log(`Created output directory: ${outDirectory}`);
  }

  const [
    nftFreelist,
    nftWhitelist,
    tokenAirdroplist,
    tokenSeedlist,
    tokenPrelist,
  ] = await Promise.all(inputFiles.map(readJsonFile));

  await Promise.all([
    generateProofs(nftFreelist, "nft-freelist-proofs.json"),
    generateProofs(nftWhitelist, "nft-whitelist-proofs.json"),
    generateProofs(tokenAirdroplist, "token-airdrop-proofs.json"),
    generateProofs(tokenSeedlist, "token-seedsale-proofs.json"),
    generateProofs(tokenPrelist, "token-presale-proofs.json"),
  ]);

  console.log("Done!");
}

main().catch((e) => console.error(e));
