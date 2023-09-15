import { BrowserRouter, Routes, Route } from "react-router-dom";

import HomePage from "./pages/HomePage";
import NFTSalesPage from "./pages/NFTSalesPage";
import Navbar from "./components/Navbar";
import TokenSalesPage from "./pages/TokenSalesPage";
import StakingPage from "./pages/StakingPage";
import AboutPage from "./pages/AboutPage";

import {
  EthereumClient,
  w3mConnectors,
  w3mProvider,
} from "@web3modal/ethereum";
import { Web3Modal } from "@web3modal/react";
import { configureChains, createConfig, WagmiConfig } from "wagmi";
import { avalancheFuji } from "wagmi/chains";

declare global {
  interface Window {
    ethereum?: any;
  }
}

const chains = [avalancheFuji];
const projectId = process.env.REACT_APP_WALLET_CONNECT_ID as string;

const { publicClient } = configureChains(chains, [w3mProvider({ projectId })]);
const wagmiConfig = createConfig({
  autoConnect: true,
  connectors: w3mConnectors({ projectId, chains }),
  publicClient,
});
const ethereumClient = new EthereumClient(wagmiConfig, chains);

function App() {
  return (
    <BrowserRouter basename="/">
      <WagmiConfig config={wagmiConfig}>
        <Navbar />
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/nft-sales-page" element={<NFTSalesPage />} />
          <Route path="/token-sales-page" element={<TokenSalesPage />} />
          <Route path="/staking-page" element={<StakingPage />} />
          <Route path="/about-page" element={<AboutPage />} />
        </Routes>
      </WagmiConfig>
      <Web3Modal projectId={projectId} ethereumClient={ethereumClient} />
    </BrowserRouter>
  );
}

export default App;
