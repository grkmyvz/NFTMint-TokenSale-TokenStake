import { useEffect, useState } from "react";
import { publicClient, walletClient } from "../helpers/clients";
import {
  tokenSaleContractAddress,
  tokenSaleContractAbi,
} from "../helpers/TokenSaleInfo";
import { formatTimeDiff } from "../helpers/calculeteTime";
import { checkProof } from "../helpers/proofs";
import { createMulticall } from "../helpers/createMulticall";

import List from "../components/List";

export default function TokenSalesPage() {
  const [tokenSaleContractVariables, setTokenSaleContractVariables] = useState({
    airdropAmount: 0,
    airdropMaxPerWallet: 0,
    airdropClaimStartTime: 0,
    airdropClaimPeriod: 0,
    seedsaleAmount: 0,
    seedsaleMaxPerWallet: 0,
    seedsalePrice: 0,
    seedsaleClaimStartTime: 0,
    seedsaleClaimPeriod: 0,
    presaleAmount: 0,
    presaleMaxPerWallet: 0,
    presalePrice: 0,
    presaleClaimStartTime: 0,
    presaleClaimPeriod: 0,
    publicsaleAmount: 0,
    publicsaleMaxPerWallet: 0,
    publicsalePrice: 0,
    publicsaleClaimStartTime: 0,
    publicsaleClaimPeriod: 0,
    periodTime: 0,
    airdropStatus: false,
    seedsaleStatus: false,
    presaleStatus: false,
    publicsaleStatus: false,
    isTokenBalanceOk: false,
    airdropBuyed: 0,
    seedsaleBuyed: 0,
    presaleBuyed: 0,
    publicsaleBuyed: 0,
    tokenAddress: "",
  });
  const [buySeedSaleAmount, setBuySeedSaleAmount] = useState(1);
  const [buyPreSaleAmount, setBuyPreSaleAmount] = useState(1);
  const [buyPublicSaleAmount, setBuyPublicSaleAmount] = useState(1);
  const [claimAirdropPeriod, setClaimAirdropPeriod] = useState(1);
  const [claimSeedsalePeriod, setClaimSeedsalePeriod] = useState(1);
  const [claimPresalePeriod, setClaimPresalePeriod] = useState(1);
  const [claimPublicsalePeriod, setClaimPublicsalePeriod] = useState(1);
  const [responseMessage, setResponseMessage] = useState("");

  async function readTokenSaleContract() {
    const contractParams = {
      address: tokenSaleContractAddress,
      abi: tokenSaleContractAbi,
    } as const;

    const [
      airdropAmount,
      airdropMaxPerWallet,
      airdropClaimStartTime,
      airdropClaimPeriod,
      seedsaleAmount,
      seedsaleMaxPerWallet,
      seedsalePrice,
      seedsaleClaimStartTime,
      seedsaleClaimPeriod,
      presaleAmount,
      presaleMaxPerWallet,
      presalePrice,
      presaleClaimStartTime,
      presaleClaimPeriod,
      publicsaleAmount,
      publicsaleMaxPerWallet,
      publicsalePrice,
      publicsaleClaimStartTime,
      publicsaleClaimPeriod,
      periodTime,
      airdropStatus,
      seedsaleStatus,
      presaleStatus,
      publicsaleStatus,
      isTokenBalanceOk,
      airdropBuyed,
      seedsaleBuyed,
      presaleBuyed,
      publicsaleBuyed,
      token,
    ] = await publicClient.multicall({
      contracts: createMulticall(contractParams, [
        "AIRDROP_AMOUNT",
        "AIRDROP_MAX_PER_WALLET",
        "AIRDROP_CLAIM_START_TIME",
        "AIRDROP_CLAIM_PERIOD",
        "SEEDSALE_AMOUNT",
        "SEEDSALE_MAX_PER_WALLET",
        "SEEDSALE_PRICE",
        "SEEDSALE_CLAIM_START_TIME",
        "SEEDSALE_CLAIM_PERIOD",
        "PRESALE_AMOUNT",
        "PRESALE_MAX_PER_WALLET",
        "PRESALE_PRICE",
        "PRESALE_CLAIM_START_TIME",
        "PRESALE_CLAIM_PERIOD",
        "PUBLICSALE_AMOUNT",
        "PUBLICSALE_MAX_PER_WALLET",
        "PUBLICSALE_PRICE",
        "PUBLICSALE_CLAIM_START_TIME",
        "PUBLICSALE_CLAIM_PERIOD",
        "PERIOD_TIME",
        "airdropStatus",
        "seedsaleStatus",
        "presaleStatus",
        "publicsaleStatus",
        "isTokenBalanceOk",
        "airdropBuyed",
        "seedsaleBuyed",
        "presaleBuyed",
        "publicsaleBuyed",
        "token",
      ]),
    });

    setTokenSaleContractVariables({
      airdropAmount: Number(airdropAmount.result),
      airdropMaxPerWallet: Number(airdropMaxPerWallet.result),
      airdropClaimStartTime: Number(airdropClaimStartTime.result),
      airdropClaimPeriod: Number(airdropClaimPeriod.result),
      seedsaleAmount: Number(seedsaleAmount.result),
      seedsaleMaxPerWallet: Number(seedsaleMaxPerWallet.result),
      seedsalePrice: Number(seedsalePrice.result),
      seedsaleClaimStartTime: Number(seedsaleClaimStartTime.result),
      seedsaleClaimPeriod: Number(seedsaleClaimPeriod.result),
      presaleAmount: Number(presaleAmount.result),
      presaleMaxPerWallet: Number(presaleMaxPerWallet.result),
      presalePrice: Number(presalePrice.result),
      presaleClaimStartTime: Number(presaleClaimStartTime.result),
      presaleClaimPeriod: Number(presaleClaimPeriod.result),
      publicsaleAmount: Number(publicsaleAmount.result),
      publicsaleMaxPerWallet: Number(publicsaleMaxPerWallet.result),
      publicsalePrice: Number(publicsalePrice.result),
      publicsaleClaimStartTime: Number(publicsaleClaimStartTime.result),
      publicsaleClaimPeriod: Number(publicsaleClaimPeriod.result),
      periodTime: Number(periodTime.result),
      airdropStatus: airdropStatus.result as boolean,
      seedsaleStatus: seedsaleStatus.result as boolean,
      presaleStatus: presaleStatus.result as boolean,
      publicsaleStatus: publicsaleStatus.result as boolean,
      isTokenBalanceOk: isTokenBalanceOk.result as boolean,
      airdropBuyed: Number(airdropBuyed.result),
      seedsaleBuyed: Number(seedsaleBuyed.result),
      presaleBuyed: Number(presaleBuyed.result),
      publicsaleBuyed: Number(publicsaleBuyed.result),
      tokenAddress: token.result as string,
    });

    setBuySeedSaleAmount(Number(seedsaleClaimPeriod.result));
    setBuyPreSaleAmount(Number(presaleClaimPeriod.result));
    setBuyPublicSaleAmount(Number(publicsaleClaimPeriod.result));
  }

  async function buyAirdropButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: tokenSaleContractAddress,
        abi: tokenSaleContractAbi,
        functionName: "buyAirdrop",
        args: [checkProof("token-airdrop", account)],
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Buy Airdrop Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  async function buySeedsaleButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: tokenSaleContractAddress,
        abi: tokenSaleContractAbi,
        functionName: "buySeedsale",
        args: [
          checkProof("token-seedsale", account),
          BigInt(buySeedSaleAmount),
        ],
        value: BigInt(
          buySeedSaleAmount * tokenSaleContractVariables.seedsalePrice
        ),
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Buy Seed Sale Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  async function buyPresaleButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: tokenSaleContractAddress,
        abi: tokenSaleContractAbi,
        functionName: "buyPresale",
        args: [checkProof("token-presale", account), BigInt(buyPreSaleAmount)],
        value: BigInt(
          buyPreSaleAmount * tokenSaleContractVariables.presalePrice
        ),
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Buy Pre Sale Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  async function buyPublicsaleButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: tokenSaleContractAddress,
        abi: tokenSaleContractAbi,
        functionName: "buyPublicsale",
        args: [BigInt(buyPublicSaleAmount)],
        value: BigInt(
          buyPublicSaleAmount * tokenSaleContractVariables.publicsalePrice
        ),
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Buy Public Sale Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  async function claimAirdropButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: tokenSaleContractAddress,
        abi: tokenSaleContractAbi,
        functionName: "claimAirdrop",
        args: [BigInt(claimAirdropPeriod)],
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Claim Airdrop Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  async function claimSeedsaleButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: tokenSaleContractAddress,
        abi: tokenSaleContractAbi,
        functionName: "claimSeedsale",
        args: [BigInt(claimSeedsalePeriod)],
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Claim Seed Sale Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  async function claimPresaleButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: tokenSaleContractAddress,
        abi: tokenSaleContractAbi,
        functionName: "claimPresale",
        args: [BigInt(claimPresalePeriod)],
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Claim Pre Sale Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  async function claimPublicsaleButton() {
    try {
      const [account] = await walletClient.getAddresses();
      const { request } = await publicClient.simulateContract({
        account,
        address: tokenSaleContractAddress,
        abi: tokenSaleContractAbi,
        functionName: "claimPublicsale",
        args: [BigInt(claimPublicsalePeriod)],
      });
      const tx = await walletClient.writeContract(request);
      setResponseMessage(`Claim Public Sale Success: ${tx}`);
    } catch (e: any) {
      setResponseMessage(e.toString());
      console.error(e);
    }
  }

  useEffect(() => {
    readTokenSaleContract();
  }, []);

  return (
    <div>
      <h1 style={{ textAlign: "center" }}>Token Sale Page</h1>
      <p style={{ textAlign: "center" }}>This is the Token Sale page.</p>
      <List
        listTitle={"Contract Detail"}
        listParams={[
          {
            listName: "Address",
            listValue: tokenSaleContractVariables.tokenAddress,
          },
          {
            listName: "Balance",
            listValue: tokenSaleContractVariables.isTokenBalanceOk
              ? "Tokens are in contract."
              : "Tokens aren't in contract.",
          },
          {
            listName: "Period Time",
            listValue: tokenSaleContractVariables.periodTime.toString(),
          },
        ]}
      />
      <List
        listTitle={"Buyed Amount"}
        listParams={[
          {
            listName: "Airdrop Buyed",
            listValue: tokenSaleContractVariables.airdropBuyed.toString(),
          },
          {
            listName: "Seed Sale Buyed",
            listValue: tokenSaleContractVariables.seedsaleBuyed.toString(),
          },
          {
            listName: "Pre Sale Buyed",
            listValue: tokenSaleContractVariables.presaleBuyed.toString(),
          },
          {
            listName: "Public Sale Buyed",
            listValue: tokenSaleContractVariables.publicsaleBuyed.toString(),
          },
        ]}
      />
      <List
        listTitle={"Airdrop"}
        listParams={[
          {
            listName: "Amount",
            listValue: tokenSaleContractVariables.airdropAmount.toString(),
          },
          {
            listName: "Max Per Wallet",
            listValue:
              tokenSaleContractVariables.airdropMaxPerWallet.toString(),
          },
          {
            listName: "Price",
            listValue: "Free",
          },
          {
            listName: "Claim Start Time",
            listValue: formatTimeDiff(
              tokenSaleContractVariables.airdropClaimStartTime
            ),
          },
          {
            listName: "Claim Period",
            listValue: tokenSaleContractVariables.airdropClaimPeriod.toString(),
          },
          {
            listName: "Status",
            listValue: tokenSaleContractVariables.airdropStatus
              ? "Active"
              : "Inactive",
          },
        ]}
      />
      <List
        listTitle={"Seed Sale"}
        listParams={[
          {
            listName: "Amount",
            listValue: tokenSaleContractVariables.seedsaleAmount.toString(),
          },
          {
            listName: "Max Per Wallet",
            listValue:
              tokenSaleContractVariables.seedsaleMaxPerWallet.toString(),
          },
          {
            listName: "Price",
            listValue: (
              tokenSaleContractVariables.seedsalePrice /
              10 ** 18
            ).toString(),
          },
          {
            listName: "Claim Start Time",
            listValue: formatTimeDiff(
              tokenSaleContractVariables.seedsaleClaimStartTime
            ),
          },
          {
            listName: "Claim Period",
            listValue:
              tokenSaleContractVariables.seedsaleClaimPeriod.toString(),
          },
          {
            listName: "Status",
            listValue: tokenSaleContractVariables.seedsaleStatus
              ? "Active"
              : "Inactive",
          },
        ]}
      />
      <List
        listTitle={"Pre Sale"}
        listParams={[
          {
            listName: "Amount",
            listValue: tokenSaleContractVariables.presaleAmount.toString(),
          },
          {
            listName: "Max Per Wallet",
            listValue:
              tokenSaleContractVariables.presaleMaxPerWallet.toString(),
          },
          {
            listName: "Price",
            listValue: (
              tokenSaleContractVariables.presalePrice /
              10 ** 18
            ).toString(),
          },
          {
            listName: "Claim Start Time",
            listValue: formatTimeDiff(
              tokenSaleContractVariables.presaleClaimStartTime
            ),
          },
          {
            listName: "Claim Period",
            listValue: tokenSaleContractVariables.presaleClaimPeriod.toString(),
          },
          {
            listName: "Status",
            listValue: tokenSaleContractVariables.presaleStatus
              ? "Active"
              : "Inactive",
          },
        ]}
      />
      <List
        listTitle={"Public Sale"}
        listParams={[
          {
            listName: "Amount",
            listValue: tokenSaleContractVariables.publicsaleAmount.toString(),
          },
          {
            listName: "Max Per Wallet",
            listValue:
              tokenSaleContractVariables.publicsaleMaxPerWallet.toString(),
          },
          {
            listName: "Price",
            listValue: (
              tokenSaleContractVariables.publicsalePrice /
              10 ** 18
            ).toString(),
          },
          {
            listName: "Claim Start Time",
            listValue: formatTimeDiff(
              tokenSaleContractVariables.publicsaleClaimStartTime
            ),
          },
          {
            listName: "Claim Period",
            listValue:
              tokenSaleContractVariables.publicsaleClaimPeriod.toString(),
          },
          {
            listName: "Status",
            listValue: tokenSaleContractVariables.publicsaleStatus
              ? "Active"
              : "Inactive",
          },
        ]}
      />
      <div style={{ display: "flex", textAlign: "center" }}>
        <div style={{ flex: 1 }}>
          <h3>Buy Airdrop</h3>
          <input
            type="number"
            max={tokenSaleContractVariables.airdropMaxPerWallet}
            min={tokenSaleContractVariables.airdropClaimPeriod}
            placeholder={`Fixed Amount (${tokenSaleContractVariables.airdropMaxPerWallet})`}
            disabled
            style={{ width: "50%" }}
          />
          <br />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={buyAirdropButton}
          >
            Buy Airdrop
          </button>
        </div>
        <div style={{ flex: 1 }}>
          <h3>Buy Seed Sale</h3>
          <input
            type="number"
            max={tokenSaleContractVariables.seedsaleMaxPerWallet}
            min={tokenSaleContractVariables.seedsaleClaimPeriod}
            value={buySeedSaleAmount}
            onChange={(e) => setBuySeedSaleAmount(Number(e.target.value))}
            style={{ width: "50%" }}
          />
          <br />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={buySeedsaleButton}
          >
            Buy Seed Sale
          </button>
        </div>
        <div style={{ flex: 1 }}>
          <h3>Buy Pre Sale</h3>
          <input
            type="number"
            max={tokenSaleContractVariables.presaleMaxPerWallet}
            min={tokenSaleContractVariables.presaleClaimPeriod}
            value={buyPreSaleAmount}
            onChange={(e) => setBuyPreSaleAmount(Number(e.target.value))}
            style={{ width: "50%" }}
          />
          <br />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={buyPresaleButton}
          >
            Buy Pre Sale
          </button>
        </div>
        <div style={{ flex: 1 }}>
          <h3>Buy Public Sale</h3>
          <input
            type="number"
            max={tokenSaleContractVariables.publicsaleMaxPerWallet}
            min={tokenSaleContractVariables.publicsaleClaimPeriod}
            value={buyPublicSaleAmount}
            onChange={(e) => setBuyPublicSaleAmount(Number(e.target.value))}
            style={{ width: "50%" }}
          />
          <br />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={buyPublicsaleButton}
          >
            Buy Public Sale
          </button>
        </div>
      </div>
      <hr />
      <div style={{ display: "flex", textAlign: "center" }}>
        <div style={{ flex: 1 }}>
          <h3>Claim Airdrop</h3>
          <input
            type="number"
            max={tokenSaleContractVariables.airdropClaimPeriod}
            min={1}
            value={claimAirdropPeriod}
            onChange={(e) => setClaimAirdropPeriod(Number(e.target.value))}
            style={{ width: "50%" }}
          />
          <br />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={claimAirdropButton}
          >
            Claim Airdrop
          </button>
        </div>
        <div style={{ flex: 1 }}>
          <h3>Claim Seed Sale</h3>
          <input
            type="number"
            max={tokenSaleContractVariables.seedsaleClaimPeriod}
            min={1}
            value={claimSeedsalePeriod}
            onChange={(e) => setClaimSeedsalePeriod(Number(e.target.value))}
            style={{ width: "50%" }}
          />
          <br />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={claimSeedsaleButton}
          >
            Claim Seed Sale
          </button>
        </div>
        <div style={{ flex: 1 }}>
          <h3>Claim Pre Sale</h3>
          <input
            type="number"
            max={tokenSaleContractVariables.presaleClaimPeriod}
            min={1}
            value={claimPresalePeriod}
            onChange={(e) => setClaimPresalePeriod(Number(e.target.value))}
            style={{ width: "50%" }}
          />
          <br />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={claimPresaleButton}
          >
            Claim Pre Sale
          </button>
        </div>
        <div style={{ flex: 1 }}>
          <h3>Claim Public Sale</h3>
          <input
            type="number"
            max={tokenSaleContractVariables.publicsaleClaimPeriod}
            min={1}
            value={claimPublicsalePeriod}
            onChange={(e) => setClaimPublicsalePeriod(Number(e.target.value))}
            style={{ width: "50%" }}
          />
          <br />
          <button
            style={{ margin: "0.5rem", padding: "0.5rem" }}
            onClick={claimPublicsaleButton}
          >
            Claim Public Sale
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
