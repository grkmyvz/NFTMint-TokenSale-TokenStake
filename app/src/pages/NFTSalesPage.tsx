import { useState, useEffect } from "react";
import { publicClient, walletClient } from "../helpers/clients";
import { nftContractAddress, nftContractAbi } from "../helpers/NFTContractInfo";
import { checkProof } from "../helpers/proofs";
import { createMulticall } from "../helpers/createMulticall";

import List from "../components/List";

export default function NFTSalesPage() {
  const [nftContractVariables, setNftContractVariables] = useState({
    name: "",
    symbol: "",
    totalSupply: 0,
    maxSupply: 0,
    freePerWallet: 0,
    whitelistPerWallet: 0,
    whitelistPrice: 0,
    publicPerWallet: 0,
    publicPrice: 0,
    isFreeMintStarted: false,
    isWhitelistMintStarted: false,
    isPublicMintStarted: false,
  });
  const [freeMintAmount, setFreeMintAmount] = useState(1);
  const [whitelistMintAmount, setWhitelistMintAmount] = useState(1);
  const [publicMintAmount, setPublicMintAmount] = useState(1);
  const [responseMessage, setResponseMessage] = useState("");
  //const { address: walletAddress } = useAccount();

  async function readNFTContract() {
    const contractParams = {
      address: nftContractAddress,
      abi: nftContractAbi,
    } as const;

    const [
      name,
      symbol,
      totalSupply,
      maxSupply,
      freePerWallet,
      whitelistPerWallet,
      whitelistPrice,
      publicPerWallet,
      publicPrice,
      isFreeMintStarted,
      isWhitelistMintStarted,
      isPublicMintStarted,
    ] = await publicClient.multicall({
      contracts: createMulticall(contractParams, [
        "name",
        "symbol",
        "totalSupply",
        "MAX_SUPPLY",
        "FREE_PER_WALLET",
        "WHITELIST_PER_WALLET",
        "WHITELIST_PRICE",
        "PUBLIC_PER_WALLET",
        "PUBLIC_PRICE",
        "isFreeMintStarted",
        "isWhitelistMintStarted",
        "isPublicMintStarted",
      ]),
    });

    setNftContractVariables({
      name: name.result as string,
      symbol: symbol.result as string,
      totalSupply: Number(totalSupply.result),
      maxSupply: Number(maxSupply.result),
      freePerWallet: Number(freePerWallet.result),
      whitelistPerWallet: Number(whitelistPerWallet.result),
      whitelistPrice: Number(whitelistPrice.result),
      publicPerWallet: Number(publicPerWallet.result),
      publicPrice: Number(publicPrice.result),
      isFreeMintStarted: isFreeMintStarted.result as boolean,
      isWhitelistMintStarted: isWhitelistMintStarted.result as boolean,
      isPublicMintStarted: isPublicMintStarted.result as boolean,
    });
  }

  async function freeMintButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: nftContractAddress,
        abi: nftContractAbi,
        functionName: "freeMint",
        args: [checkProof("nft-freelist", account), BigInt(freeMintAmount)],
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Free Mint Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  async function whitelistMintButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: nftContractAddress,
        abi: nftContractAbi,
        functionName: "whitelistMint",
        args: [
          checkProof("nft-whitelist", account),
          BigInt(whitelistMintAmount),
        ],
        value: BigInt(
          whitelistMintAmount * nftContractVariables.whitelistPrice
        ),
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Whitelist Mint Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  async function publicMintButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: nftContractAddress,
        abi: nftContractAbi,
        functionName: "publicMint",
        args: [BigInt(publicMintAmount)],
        value: BigInt(publicMintAmount * nftContractVariables.publicPrice),
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Public Mint Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }
  useEffect(() => {
    readNFTContract();
  }, []);

  return (
    <div>
      <h1 style={{ textAlign: "center" }}>NFT Sale Page</h1>
      <p style={{ textAlign: "center" }}>This is the NFT Sale page.</p>
      <List
        listParams={[
          { listName: "Name", listValue: nftContractVariables.name },
          { listName: "Symbol", listValue: nftContractVariables.symbol },
          {
            listName: "Total Supply",
            listValue: nftContractVariables.totalSupply.toString(),
          },
          {
            listName: "Max Supply",
            listValue: nftContractVariables.maxSupply.toString(),
          },
        ]}
      />
      <List
        listParams={[
          {
            listName: "Is Free Mint Started",
            listValue: nftContractVariables.isFreeMintStarted
              ? "Open"
              : "Close",
          },
          {
            listName: "Free Per Wallet",
            listValue: nftContractVariables.freePerWallet.toString(),
          },
          {
            listName: "Free Price",
            listValue: "Free",
          },
        ]}
      />
      <List
        listParams={[
          {
            listName: "Is Whitelist Mint Started",
            listValue: nftContractVariables.isWhitelistMintStarted
              ? "Open"
              : "Close",
          },
          {
            listName: "Whitelist Per Wallet",
            listValue: nftContractVariables.whitelistPerWallet.toString(),
          },
          {
            listName: "Whitelist Price",
            listValue: (
              nftContractVariables.whitelistPrice /
              10 ** 18
            ).toString(),
          },
        ]}
      />
      <List
        listParams={[
          {
            listName: "Is Public Mint Started",
            listValue: nftContractVariables.isPublicMintStarted
              ? "Open"
              : "Close",
          },
          {
            listName: "Public Per Wallet",
            listValue: nftContractVariables.publicPerWallet.toString(),
          },
          {
            listName: "Public Price",
            listValue: (nftContractVariables.publicPrice / 10 ** 18).toString(),
          },
        ]}
      />
      <div style={{ display: "flex", textAlign: "center" }}>
        <div style={{ flex: 1 }}>
          <h3>Free Mint</h3>
          <img
            src={"https://placehold.co/600x400?text=Free+Mint+Cover"}
            alt={"Free mint cover"}
            style={{ width: "90%" }}
          />
          <hr style={{ marginLeft: 10, marginRight: 10 }} />
          <input
            type="number"
            max={nftContractVariables.freePerWallet}
            min={1}
            value={freeMintAmount}
            placeholder="Amount"
            onChange={(e) => setFreeMintAmount(Number(e.target.value))}
            style={{ width: "30%" }}
          />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={freeMintButton}
          >
            Free mint
          </button>
        </div>
        <div style={{ flex: 1 }}>
          <h3>Whitelist Mint</h3>
          <img
            src={"https://placehold.co/600x400?text=Whitelist+Mint+Cover"}
            alt={"Whitelist mint cover"}
            style={{ width: "90%" }}
          />
          <hr style={{ marginLeft: 10, marginRight: 10 }} />
          <input
            type="number"
            max={nftContractVariables.whitelistPerWallet}
            min={1}
            value={whitelistMintAmount}
            placeholder="Amount"
            onChange={(e) => setWhitelistMintAmount(Number(e.target.value))}
            style={{ width: "30%" }}
          />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={whitelistMintButton}
          >
            Whitelist mint
          </button>
        </div>
        <div style={{ flex: 1 }}>
          <h3>Public Mint</h3>
          <img
            src={"https://placehold.co/600x400?text=Public+Mint+Cover"}
            alt={"Public mint cover"}
            style={{ width: "90%" }}
          />
          <hr style={{ marginLeft: 10, marginRight: 10 }} />
          <input
            type="number"
            max={nftContractVariables.publicPerWallet}
            min={1}
            value={publicMintAmount}
            placeholder="Amount"
            onChange={(e) => setPublicMintAmount(Number(e.target.value))}
            style={{ width: "30%" }}
          />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={publicMintButton}
          >
            Public mint
          </button>
        </div>
      </div>
      <div
        style={{
          border: "1px solid black",
          marginTop: "0.5rem",
          padding: "0.5rem",
        }}
      >
        <h4>Errors and Responses:</h4>
        <p>{responseMessage}</p>
      </div>
    </div>
  );
}
