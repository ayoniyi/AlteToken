# AlteToken Deployment Guide

This guide shows how to deploy the AlteToken smart contract to the Sepolia testnet and retrieve its contract address.

## Prerequisites

- Node.js and npm installed
- Metamask or another Ethereum wallet with Sepolia ETH
- An API key from Infura, Alchemy, or Ankr
- An Etherscan API key (for contract verification)

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

1. Copy the .env.example file to .env:

```bash
cp .env.example .env
```

2. Edit the .env file with your actual values:

```
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
PRIVATE_KEY=your_wallet_private_key_here_without_0x_prefix
ETHERSCAN_API_KEY=your_etherscan_api_key_here
TEAM_WALLET_ADDRESS=your_team_wallet_address
RESERVE_WALLET_ADDRESS=your_reserve_wallet_address
```

Important notes:

- The `PRIVATE_KEY` should be from a wallet with Sepolia ETH
- You can get Sepolia ETH from a faucet like https://sepoliafaucet.com/
- Never share your .env file or private key
- For testing, use test wallets, not your main wallets

### 3. Update Deployment Parameters (if needed)

If you want to modify the deployment parameters, edit `scripts/deploy.js`:

- Update the `tokenURI` to point to your token metadata
- You can also modify any other constructor parameters as needed

### 4. Compile the Contract

```bash
npx hardhat compile
```

### 5. Deploy to Sepolia Testnet

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

Upon successful deployment, you'll see output similar to:

```
Deploying AlteToken with the following parameters:
Team Wallet: 0x...
Reserve Wallet: 0x...
Token URI: https://alte.token/metadata
AlteToken deployed to: 0x...
Waiting for confirmations...
Deployment confirmed in block: 12345678
Gas used: 1234567

Verify with:
npx hardhat verify --network sepolia 0x... "0x..." "0x..." "https://alte.token/metadata"
```

The contract address will be displayed after "AlteToken deployed to:".

### 6. Verify Contract on Etherscan (Optional)

Run the verify command provided in the deployment output:

```bash
npx hardhat verify --network sepolia CONTRACT_ADDRESS TEAM_WALLET RESERVE_WALLET TOKEN_URI
```

### 7. Check Your Token on Etherscan

Visit https://sepolia.etherscan.io/address/YOUR_CONTRACT_ADDRESS to view your deployed token.

## Troubleshooting

- **Transaction Underpriced**: Increase the `gasMultiplier` in hardhat.config.js
- **Not enough ETH**: Get more Sepolia ETH from a faucet
- **Nonce too low**: Reset your account in MetaMask or use the correct nonce in your transaction

## Additional Notes

- The owner of the token will receive 80% of the total supply (60% for ICO, 20% for staking rewards)
- The team wallet will receive 15% of the total supply
- The reserve wallet will receive 5% of the total supply
- Only the owner can execute privileged functions like updating blacklists, pausing the token, etc.
