# Alté Token (ALT)



## Overview

Alté Token (ALT) is an ERC20 token built on Ethereum with enhanced security features, designed specifically for the Alté ecosystem. This token implements multiple security measures including anti-bot protection, blacklisting capabilities, and pause functionality to ensure a safe trading environment.

## Key Features

- **Enhanced Security**: Includes protection against reentrancy attacks, blacklisting capabilities, and pausable functionality
- **Transparent Distribution**: Clear allocation of tokens (60% ICO, 20% staking rewards, 15% team, 5% reserve)
- **Token Recovery**: Built-in functionality to recover ERC20 tokens accidentally sent to the contract
- **Ownership Management**: Secure two-step ownership transfer process
- **Metadata Support**: Includes tokenURI for metadata (logo, description, etc.)

## Token Information

- **Name**: Alté
- **Symbol**: ALT
- **Decimals**: 18
- **Total Supply**: 100,000,000 tokens (100 million)

## Token Distribution

The token supply is distributed as follows:

- **ICO Portion**: 60,000,000 tokens (60% of total supply)
- **Staking Rewards**: 20,000,000 tokens (20% of total supply)
- **Team Allocation**: 15,000,000 tokens (15% of total supply)
- **Reserve Fund**: 5,000,000 tokens (5% of total supply)

## Getting Started

### Prerequisites

- Node.js and npm
- Hardhat for development and deployment
- An Ethereum wallet with ETH for gas

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/alteToken.git
cd alteToken
```

2. Install dependencies:

```bash
npm install
```

3. Compile the contracts:

```bash
npx hardhat compile
```

## Usage

### Running Tests

```bash
npx hardhat test
```

### Local Development

You can run a local Hardhat node for development:

```bash
npx hardhat node
```

### Deployment

For detailed deployment instructions, see [deploy.md](./deploy.md).

## Technical Details

### Smart Contract Architecture

The AlteToken contract inherits from:

- ERC20 (from OpenZeppelin via library.sol)
- ReentrancyGuard for protection against reentrancy attacks

### Security Features

- **Blacklisting**: The contract owner can blacklist addresses to prevent them from sending or receiving tokens
- **Pause Functionality**: The contract can be paused in emergencies to prevent all transfers
- **Anti-Bot Measures**: Includes protection against automated trading bots
- **Recovery Function**: Allows recovery of ERC20 tokens accidentally sent to the contract

### Owner Privileges

The contract owner can:

- Add or remove addresses from the blacklist
- Pause or unpause token transfers
- Recover accidentally sent ERC20 tokens
- Transfer ownership via a secure two-step process

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please contact the team at [contact@alte.token](mailto:contact@alte.token).
