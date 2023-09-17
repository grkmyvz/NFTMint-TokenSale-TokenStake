/* import { freelistProofs } from "./FreelistProofs";
import { whitelistProofs } from "./WhitelistProofs"; */
import nftFreelistProofsJson from "../proofs/nft-freelist-proofs.json";
import nftWhitelistProofsJson from "../proofs/nft-whitelist-proofs.json";
import tokenAirdropProofsJson from "../proofs/token-airdrop-proofs.json";
import tokenSeedsaleProofsJson from "../proofs/token-seedsale-proofs.json";
import tokenPresaleProofsJson from "../proofs/token-presale-proofs.json";
import { Hex, Proof, ProofList } from "./types";

function getProofs(listName: string): ProofList | null {
  switch (listName) {
    case "nft-freelist":
      return nftFreelistProofsJson as ProofList;
    case "nft-whitelist":
      return nftWhitelistProofsJson as ProofList;
    case "token-airdrop":
      return tokenAirdropProofsJson as ProofList;
    case "token-seedsale":
      return tokenSeedsaleProofsJson as ProofList;
    case "token-presale":
      return tokenPresaleProofsJson as ProofList;
    default:
      return null;
  }
}

export function checkProof(listName: string, address: Hex): Hex[] {
  const proofs = getProofs(listName);
  if (proofs !== null) {
    const proof = proofs.proofs.find(
      (proof: Proof) => proof.address === address
    );
    if (proof) {
      return proof.proof;
    }
    return [];
  } else {
    return [];
  }
}
