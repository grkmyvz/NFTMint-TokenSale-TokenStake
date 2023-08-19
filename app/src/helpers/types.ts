export type Hex = `0x${string}`;

export type Proof = {
  address: Hex;
  proof: Hex[];
};

export type ProofList = {
  merkleRoot: Hex;
  proofs: Proof[];
};

export type ListParams = {
  listName: string;
  listValue: string;
};
