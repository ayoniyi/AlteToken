// deploy.js - Script to deploy AlteToken contract

const hre = require("hardhat");

async function main() {
  // Get the contract factory
  const AlteToken = await hre.ethers.getContractFactory("AlteToken");

  // Define constructor parameters
  const teamWallet = process.env.TEAM_WALLET_ADDRESS || "0x..."; // Replace with your team wallet address if not in .env
  const reserveWallet = process.env.RESERVE_WALLET_ADDRESS || "0x..."; // Replace with your reserve wallet address if not in .env
  const tokenURI = "https://alte.token/metadata"; // Update to your metadata URI

  console.log("Deploying AlteToken with the following parameters:");
  console.log(`Team Wallet: ${teamWallet}`);
  console.log(`Reserve Wallet: ${reserveWallet}`);
  console.log(`Token URI: ${tokenURI}`);

  // Deploy the contract
  const alteToken = await AlteToken.deploy(teamWallet, reserveWallet, tokenURI);

  // Wait for deployment to finish
  await alteToken.waitForDeployment();

  // Get the deployed contract address
  const alteTokenAddress = await alteToken.getAddress();

  console.log(`AlteToken deployed to: ${alteTokenAddress}`);

  // Wait for several confirmations to ensure the contract is properly deployed
  console.log("Waiting for confirmations...");
  const transactionReceipt = await alteToken.deploymentTransaction().wait(5);

  console.log(
    `Deployment confirmed in block: ${transactionReceipt.blockNumber}`
  );
  console.log(`Gas used: ${transactionReceipt.gasUsed.toString()}`);

  // Log verification command
  console.log("\nVerify with:");
  console.log(
    `npx hardhat verify --network sepolia ${alteTokenAddress} "${teamWallet}" "${reserveWallet}" "${tokenURI}"`
  );
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
