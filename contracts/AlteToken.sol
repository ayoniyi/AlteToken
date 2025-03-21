// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./library.sol";

/**
 * @title Alté Token
 * @dev Implementation of the Alté Token ERC20 token with enhanced security features
 * This token is designed to work with the TokenICO contract for initial distribution
 * and the StakingDapp contract for staking functionality
 */
contract AlteToken is ERC20, ReentrancyGuard {
    // Token owner address
    address public owner;

    // Token metadata URI (for the logo)
    string public tokenURI;

    // Total supply of tokens
    uint256 public constant TOTAL_SUPPLY = 100_000_000 * 10**18; // 100 million tokens with 18 decimals

    // Distribution portions
    uint256 public constant ICO_PORTION = 60_000_000 * 10**18; // 60% for ICO
    uint256 public constant STAKING_REWARDS = 20_000_000 * 10**18; // 20% for staking rewards
    uint256 public constant TEAM_ALLOCATION = 15_000_000 * 10**18; // 15% for team
    uint256 public constant RESERVE_FUND = 5_000_000 * 10**18; // 5% for reserve fund

    // Team wallet address
    address public teamWallet;
    // Reserve wallet address
    address public reserveWallet;

    // Mapping for blacklisted addresses
    mapping(address => bool) public blacklisted;
    
    // Pausable state
    bool public paused;
    
    // Pending ownership transfer
    address public pendingOwner;

    // Events
    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event TokenURIUpdated(string newURI);
    event WalletUpdated(string walletType, address indexed oldWallet, address indexed newWallet);
    event Paused(address account);
    event Unpaused(address account);
    event OwnershipTransferInitiated(address indexed currentOwner, address indexed pendingOwner);
    event OwnershipTransferCompleted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "AlteToken: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if the address is blacklisted.
     */
    modifier notBlacklisted(address account) {
        require(!blacklisted[account], "AlteToken: account is blacklisted");
        _;
    }
    
    /**
     * @dev Throws if the contract is paused.
     */
    modifier whenNotPaused() {
        require(!paused, "AlteToken: token transfer while paused");
        _;
    }
    
    /**
     * @dev Throws if called by any account other than the pending owner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner, "AlteToken: caller is not the pending owner");
        _;
    }

    /**
     * @dev Sets the values for {name}, {symbol}, and mints initial supply
     * Initializes the token with a total supply of 100 million tokens
     * Distributes tokens according to the allocation plan
     */
    constructor(address _teamWallet, address _reserveWallet, string memory _tokenURI) ERC20("Alte", "ALT") {
        require(_teamWallet != address(0), "AlteToken: team wallet cannot be zero address");
        require(_reserveWallet != address(0), "AlteToken: reserve wallet cannot be zero address");
        require(bytes(_tokenURI).length > 0, "AlteToken: token URI cannot be empty");

        owner = msg.sender;
        teamWallet = _teamWallet;
        reserveWallet = _reserveWallet;
        tokenURI = _tokenURI;
        paused = false;

        // Mint initial supply
        _mint(msg.sender, ICO_PORTION); // ICO tokens to owner (to be transferred to ICO contract)
        _mint(msg.sender, STAKING_REWARDS); // Staking rewards to owner (to be transferred to staking contract)
        _mint(teamWallet, TEAM_ALLOCATION); // Team allocation
        _mint(reserveWallet, RESERVE_FUND); // Reserve fund
    }

    /**
     * @dev Overrides transfer function to check if sender and recipient are not blacklisted
     * and the contract is not paused
     */
    function transfer(address recipient, uint256 amount) 
        public 
        override 
        whenNotPaused
        notBlacklisted(msg.sender) 
        notBlacklisted(recipient) 
        returns (bool) 
    {
        require(recipient != address(0), "AlteToken: transfer to the zero address");
        return super.transfer(recipient, amount);
    }

    /**
     * @dev Overrides transferFrom function to check if sender and recipient are not blacklisted
     * and the contract is not paused
     */
    function transferFrom(address sender, address recipient, uint256 amount) 
        public 
        override 
        whenNotPaused
        notBlacklisted(sender) 
        notBlacklisted(recipient) 
        returns (bool) 
    {
        require(recipient != address(0), "AlteToken: transfer to the zero address");
        return super.transferFrom(sender, recipient, amount);
    }

    /**
     * @dev Updates the blacklist status of an account
     * @param account Address to update
     * @param isBlacklisted Whether the address should be blacklisted
     */
    function updateBlacklist(address account, bool isBlacklisted) external onlyOwner nonReentrant {
        require(account != address(0), "AlteToken: cannot blacklist zero address");
        require(account != owner, "AlteToken: cannot blacklist owner");
        require(blacklisted[account] != isBlacklisted, "AlteToken: account already has that blacklist status");
        
        blacklisted[account] = isBlacklisted;
        emit BlacklistUpdated(account, isBlacklisted);
    }

    /**
     * @dev Updates the token URI (for the logo)
     * @param newURI New URI for the token metadata
     */
    function setTokenURI(string memory newURI) external onlyOwner nonReentrant {
        require(bytes(newURI).length > 0, "AlteToken: new URI cannot be empty");
        require(keccak256(bytes(newURI)) != keccak256(bytes(tokenURI)), "AlteToken: new URI is the same as current one");
        
        tokenURI = newURI;
        emit TokenURIUpdated(newURI);
    }

    /**
     * @dev Initiates ownership transfer to a new account.
     * The new owner must accept ownership by calling acceptOwnership().
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) external onlyOwner nonReentrant {
        require(newOwner != address(0), "AlteToken: new owner is the zero address");
        require(newOwner != owner, "AlteToken: new owner is the current owner");
        
        pendingOwner = newOwner;
        emit OwnershipTransferInitiated(owner, pendingOwner);
    }
    
    /**
     * @dev Completes a pending ownership transfer.
     * Can only be called by the pending owner.
     */
    function acceptOwnership() external onlyPendingOwner nonReentrant {
        address oldOwner = owner;
        owner = pendingOwner;
        pendingOwner = address(0);
        
        emit OwnershipTransferCompleted(oldOwner, owner);
        emit WalletUpdated("owner", oldOwner, owner);
    }

    /**
     * @dev Updates the team wallet address
     * @param newTeamWallet The new team wallet address
     */
    function setTeamWallet(address newTeamWallet) external onlyOwner nonReentrant {
        require(newTeamWallet != address(0), "AlteToken: new team wallet is the zero address");
        require(newTeamWallet != teamWallet, "AlteToken: new team wallet is the same as current one");
        
        address oldTeamWallet = teamWallet;
        teamWallet = newTeamWallet;
        emit WalletUpdated("team", oldTeamWallet, newTeamWallet);
    }

    /**
     * @dev Updates the reserve wallet address
     * @param newReserveWallet The new reserve wallet address
     */
    function setReserveWallet(address newReserveWallet) external onlyOwner nonReentrant {
        require(newReserveWallet != address(0), "AlteToken: new reserve wallet is the zero address");
        require(newReserveWallet != reserveWallet, "AlteToken: new reserve wallet is the same as current one");
        
        address oldReserveWallet = reserveWallet;
        reserveWallet = newReserveWallet;
        emit WalletUpdated("reserve", oldReserveWallet, newReserveWallet);
    }

    /**
     * @dev Burns tokens from the caller's account
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "AlteToken: burn amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "AlteToken: burn amount exceeds balance");
        
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev Allows owner to pause all token transfers
     */
    function pause() external onlyOwner nonReentrant {
        require(!paused, "AlteToken: token already paused");
        paused = true;
        emit Paused(msg.sender);
    }
    
    /**
     * @dev Allows owner to unpause all token transfers
     */
    function unpause() external onlyOwner nonReentrant {
        require(paused, "AlteToken: token not paused");
        paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @dev Allows owner to recover accidentally sent ERC20 tokens 
     * (this won't allow recovering ALT tokens)
     * @param tokenAddress Address of the token to recover
     * @param amount Amount to recover
     */
    function recoverERC20(address tokenAddress, uint256 amount) external onlyOwner nonReentrant {
        require(tokenAddress != address(this), "AlteToken: cannot recover ALT tokens");
        require(tokenAddress != address(0), "AlteToken: token address cannot be zero address");
        require(amount > 0, "AlteToken: recovery amount must be greater than zero");
        
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "AlteToken: insufficient balance to recover");
        
        bool success = token.transfer(owner, amount);
        require(success, "AlteToken: token transfer failed");
    }
    
    /**
     * @dev Function to check if an address is a contract
     * @param addr The address to check
     * @return true if the address is a contract, false otherwise
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
    
    /**
     * @dev Override _beforeTokenTransfer to add additional checks
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);
        
        // If this is a contract creation, skip checks
        if (from == address(0)) {
            return;
        }
        
        // Ensure we're not in a paused state
        require(!paused, "AlteToken: token transfer while paused");
        
        // Ensure neither sender nor recipient is blacklisted
        require(!blacklisted[from], "AlteToken: sender is blacklisted");
        require(!blacklisted[to], "AlteToken: recipient is blacklisted");
    }
} 