# AlteToken Contract Analysis

## Overview

The AlteToken contract is a Solidity smart contract that implements the ERC20 token standard for the Alté (ALT) token with enhanced security features. This token is specifically designed to work with the TokenICO contract for initial distribution and the StakingDapp contract for staking functionality.

## Contract Address

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
```

## Dependencies

The contract imports and inherits from:

- `ERC20`: The standard ERC20 implementation from the library.sol file
- `ReentrancyGuard`: Provides protection against reentrancy attacks
- Additionally uses `IERC20` for token recovery functionality

## Token Information

- **Name**: Alté
- **Symbol**: ALT
- **Decimals**: 18 (default from ERC20 implementation)
- **Total Supply**: 100,000,000 tokens (100 million)

## Token Distribution

The token supply is distributed as follows:

- **ICO Portion**: 60,000,000 tokens (60% of total supply)
- **Staking Rewards**: 20,000,000 tokens (20% of total supply)
- **Team Allocation**: 15,000,000 tokens (15% of total supply)
- **Reserve Fund**: 5,000,000 tokens (5% of total supply)

## Contract State Variables

- `address public owner`: The address of the contract owner
- `string public tokenURI`: URI pointing to token metadata (including logo)
- Various `constant` variables defining token supply and distribution
- `address public teamWallet`: Address receiving the team allocation
- `address public reserveWallet`: Address receiving the reserve allocation
- `mapping(address => bool) public blacklisted`: Tracks blacklisted addresses
- `bool public paused`: Flag indicating if the contract is paused
- `address public pendingOwner`: Address of the pending owner during ownership transfer

## Access Control

The contract implements multiple layers of access control:

```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "AlteToken: caller is not the owner");
    _;
}

modifier notBlacklisted(address account) {
    require(!blacklisted[account], "AlteToken: account is blacklisted");
    _;
}

modifier whenNotPaused() {
    require(!paused, "AlteToken: token transfer while paused");
    _;
}

modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner, "AlteToken: caller is not the pending owner");
    _;
}
```

## Events

The contract emits the following events:

- `BlacklistUpdated`: When an address is added to or removed from the blacklist
- `TokenURIUpdated`: When the token URI is updated
- `WalletUpdated`: When wallet addresses (owner, team, reserve) are updated
- `Paused`: When the contract is paused
- `Unpaused`: When the contract is unpaused
- `OwnershipTransferInitiated`: When an ownership transfer is initiated
- `OwnershipTransferCompleted`: When an ownership transfer is completed

## Key Functions

### Constructor

```solidity
constructor(address _teamWallet, address _reserveWallet, string memory _tokenURI) ERC20("Alté", "ALT")
```

- Initializes the token with the name "Alté" and symbol "ALT"
- Sets up wallet addresses and token URI
- Initializes the paused state to false
- Validates all input parameters
- Mints and distributes the initial token supply according to the allocation plan
- Parameters:
  - `_teamWallet`: Address to receive the team allocation
  - `_reserveWallet`: Address to receive the reserve allocation
  - `_tokenURI`: URI for token metadata (logo URL)

### transfer

```solidity
function transfer(address recipient, uint256 amount) public override whenNotPaused notBlacklisted(msg.sender) notBlacklisted(recipient) returns (bool)
```

- Overrides the standard ERC20 transfer function
- Checks that the contract is not paused
- Checks that neither the sender nor recipient is blacklisted
- Prevents transfers to the zero address
- Returns boolean indicating transfer success

### transferFrom

```solidity
function transferFrom(address sender, address recipient, uint256 amount) public override whenNotPaused notBlacklisted(sender) notBlacklisted(recipient) returns (bool)
```

- Overrides the standard ERC20 transferFrom function
- Checks that the contract is not paused
- Checks that neither the sender nor recipient is blacklisted
- Prevents transfers to the zero address
- Returns boolean indicating transfer success

### updateBlacklist

```solidity
function updateBlacklist(address account, bool isBlacklisted) external onlyOwner nonReentrant
```

- Allows the owner to add or remove addresses from the blacklist
- Protected against reentrancy attacks
- Prevents blacklisting the zero address or the owner
- Prevents redundant blacklist operations
- Parameters:
  - `account`: Address to update
  - `isBlacklisted`: Whether the address should be blacklisted or not

### setTokenURI

```solidity
function setTokenURI(string memory newURI) external onlyOwner nonReentrant
```

- Allows the owner to update the token metadata URI
- Protected against reentrancy attacks
- Validates that the new URI is not empty and is different from the current one
- Parameters:
  - `newURI`: The new URI to set

### transferOwnership

```solidity
function transferOwnership(address newOwner) external onlyOwner nonReentrant
```

- Initiates a secure two-step ownership transfer process
- Protected against reentrancy attacks
- Validates that the new owner is not the zero address or the current owner
- Parameters:
  - `newOwner`: The address of the pending new owner

### acceptOwnership

```solidity
function acceptOwnership() external onlyPendingOwner nonReentrant
```

- Completes the ownership transfer process
- Can only be called by the pending owner
- Protected against reentrancy attacks
- Resets the pending owner to the zero address

### setTeamWallet

```solidity
function setTeamWallet(address newTeamWallet) external onlyOwner nonReentrant
```

- Updates the team wallet address
- Protected against reentrancy attacks
- Validates that the new wallet is not the zero address or the current team wallet
- Parameters:
  - `newTeamWallet`: The new team wallet address

### setReserveWallet

```solidity
function setReserveWallet(address newReserveWallet) external onlyOwner nonReentrant
```

- Updates the reserve wallet address
- Protected against reentrancy attacks
- Validates that the new wallet is not the zero address or the current reserve wallet
- Parameters:
  - `newReserveWallet`: The new reserve wallet address

### burn

```solidity
function burn(uint256 amount) external whenNotPaused nonReentrant
```

- Allows any user to burn their own tokens
- Only available when the contract is not paused
- Protected against reentrancy attacks
- Validates that the amount is greater than zero and not exceeding the user's balance
- Parameters:
  - `amount`: Amount of tokens to burn

### pause

```solidity
function pause() external onlyOwner nonReentrant
```

- Allows the owner to pause all token transfers
- Protected against reentrancy attacks
- Cannot pause an already paused contract

### unpause

```solidity
function unpause() external onlyOwner nonReentrant
```

- Allows the owner to unpause all token transfers
- Protected against reentrancy attacks
- Cannot unpause a contract that's not paused

### recoverERC20

```solidity
function recoverERC20(address tokenAddress, uint256 amount) external onlyOwner nonReentrant
```

- Allows the owner to recover accidentally sent ERC20 tokens (except ALT tokens)
- Protected against reentrancy attacks
- Validates the token address and amount
- Checks that the contract has sufficient balance to recover
- Ensures the token transfer succeeds
- Parameters:
  - `tokenAddress`: Address of the token to recover
  - `amount`: Amount to recover

### \_beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal override
```

- Overrides the ERC20 hook that is called before any token transfer
- Adds additional security checks for paused state and blacklist status
- Skips checks for token minting operations

## Integration with Other Contracts

### Integration with TokenICO

- The contract mints 60% of tokens to the deployer, which can then be transferred to the TokenICO contract
- The token implements the required ERC20 interface used by TokenICO
- The deployer can call the TokenICO's `updateToken` function with this token's address

### Integration with StakingDapp

- The contract mints 20% of tokens to the deployer for staking rewards
- These tokens can be transferred to the StakingDapp contract
- The token implements the required IERC20 interface used by StakingDapp

## Security Features

1. **Blacklisting**: Prevents malicious actors from using the token
2. **Access Control**: Critical functions are protected by modifiers (onlyOwner, notBlacklisted, whenNotPaused, onlyPendingOwner)
3. **Reentrancy Protection**: All external state-changing functions are protected by the nonReentrant modifier
4. **Two-Step Ownership Transfer**: Prevents accidental transfers of ownership to incorrect addresses
5. **Pausable Functionality**: Allows freezing all token transfers in case of emergencies
6. **Input Validation**: Comprehensive input parameter validation in all functions
7. **Safe ERC20 Recovery**: Prevents the recovery of ALT tokens with multiple safety checks
8. **\_beforeTokenTransfer Protections**: Additional validation on all token transfers
9. **Standardized Implementation**: Uses battle-tested ERC20 implementation for core functionality
10. **Operation Validity Checks**: Prevents redundant operations that might waste gas

## Potential Vulnerabilities

1. **Centralized Control**: The owner has significant control, including the ability to blacklist addresses and pause the contract
2. **No Lock Period**: Team and reserve allocations don't have vesting or lock periods
3. **Pausable Risk**: If the owner's private key is compromised, an attacker could pause the contract

## Usage Flows

1. **Deployment Phase**:

   - Deploy the contract with team and reserve wallet addresses and token URI
   - Initial token supply is minted according to the allocation plan

2. **ICO Phase**:

   - Transfer ICO tokens to the TokenICO contract
   - Set the token address in the TokenICO contract

3. **Staking Phase**:

   - Transfer staking reward tokens to the StakingDapp contract
   - Add pools in the StakingDapp contract using this token

4. **Management Phase**:
   - Update blacklist if necessary
   - Update token URI if needed
   - Transfer ownership if required (two-step process)
   - Update wallet addresses if required
   - Pause/unpause the contract in case of emergencies
   - Recover accidentally sent ERC20 tokens if needed
