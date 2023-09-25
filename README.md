# NFTMint-TokenSale-TokenStake Contracts and Demo Web Page Repositories

Welcome to the NFTMint-TokenSale-TokenStake repository! This repository contains three smart contracts developed using Foundry, a library for testing smart contracts. Additionally, it includes a web3 integration with an "app" folder and a tool for generating Merkle tree hashes for wallets used in these contracts, located in the "merkletree-tool" folder with JavaScript code.

## Smart Contracts

### NFT Contract "NFTContract.sol"

The NFT Contract enables users to mint NFTs through three different minting methods:

1. **Free Mint**: Allows users to mint NFTs for free.
2. **Whitelist Mint**: Permits whitelisted users to mint NFTs.
3. **Public Mint**: Allows anyone to mint NFTs.

### Token Sale Contract "TokenSale.sol"

The Token Sale Contract facilitates the sale of created tokens through various methods, including:

1. **Airdrop**: Distributes tokens to specified addresses.
2. **Seed Sale**: Conducts token sales at seed stage.
3. **Presale**: Manages token sales during the presale phase.
4. **Public Sale**: Facilitates token sales to the public.

Please note that a "TokenStake.sol" contract is planned but has not been implemented yet.

## Installation

To set up this project, follow these steps:

1. Install Foundry by following the instructions [here](https://book.getfoundry.sh/getting-started/installation).

2. Run the installation script to install necessary packages:

```bash
./install.sh
```

3. Add the required environment variables to both the root and "./app" folders by editing the ".env" files.
   "./.env":

```js
AVALANCHE_FUJI_RPC_URL="https://api.avax-test.network/ext/bc/C/rpc"
PRIVATE_KEY=<YOUR_PRIVATE_KEY>
ETHERSCAN_API_KEY=<YOUR_ETHERSCAN_API_KEY>
```

"./app/.env":

```js
REACT_APP_WALLET_CONNECT_ID=<YOUR_WALLET_CONNECT_PROJECT_ID>
```

4. Before deploying a contract script, load the environment variables into memory:

```bash
source .env
```

Deploy the contract to the network using the following command:

```bash
forge script script/<CONTRACT_SCRIPT_FILE>.s.sol:<SCRIPT_NAME> --rpc-url $AVALANCHE_FUJI_RPC_URL --broadcast -vvvv
```

5. To verify a contract, use the following command:

```bash
forge verify-contract --chain-id 43113 --watch <CONTRACT-ADDRESS> DSSFactory
```

6. For the contracts requiring Merkle roots, update the appropriate JSON file in the "merkletree-tool" folder with the required wallet addresses. While in the "merkletree-root" directory, execute the following commands:

```bash
yarn create-proof
```

```bash
yarn release-proof
```

This will generate proofs for wallet addresses and save them in the "app" folder.

7. Locate and edit the necessary `Info.ts` file in "./app/src/helpers" with the contract address.

8. Navigate to the "app" folder in the terminal and run the following command to start the web interface:

```bash
yarn start
```

## Contribution

Feel free to contribute to this project by opening issues, providing feedback, or submitting pull requests.

## License

This project is licensed under the [MIT License](LICENSE).
Bu README.md dosyasını kullanarak projenizin kullanıcılarına kolayca kurulum yapma ve projeyi anlama konusunda yardımcı olabilirsiniz. Unutmayın ki bu sadece bir öneri olduğu için projenizin gereksinimlerine ve yapısına uygun şekilde özelleştirebilirsiniz.
