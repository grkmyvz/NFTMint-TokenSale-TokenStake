import { Web3Button } from "@web3modal/react";
import { Link } from "react-router-dom";

export default function Navbar() {
  return (
    <nav>
      <ul
        style={{
          display: "flex",
          listStyle: "none",
          justifyContent: "center",
        }}
      >
        <li style={{ marginRight: "5px", marginLeft: "5px" }}>
          <Link to="/">Homepage</Link>
        </li>
        <li style={{ marginRight: "5px", marginLeft: "5px" }}>
          <Link to="/nft-sales-page">NFT Sales</Link>
        </li>
        <li style={{ marginRight: "5px", marginLeft: "5px" }}>
          <Link to="/token-sales-page">Token Sales</Link>
        </li>
        <li style={{ marginRight: "5px", marginLeft: "5px" }}>
          <Link to="/staking-page">Staking</Link>
        </li>
        <li style={{ marginRight: "5px", marginLeft: "5px" }}>
          <Link to="/about-page">About</Link>
        </li>
      </ul>
      <div style={{ display: "flex", justifyContent: "center" }}>
        <Web3Button />
      </div>
    </nav>
  );
}
