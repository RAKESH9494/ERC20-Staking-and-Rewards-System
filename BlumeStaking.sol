// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "BLSToken.sol";
import "StakedBLSToken.sol";
// Blume Liquid Staking Contract with Token Purchase Mechanism
contract BlumeStaking is Ownable, ReentrancyGuard{
    BLSToken public blsToken;
    StakedBLSToken public stakedBLSToken;

    mapping(address => uint256) public stakedBalances;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event TokensPurchased(address indexed buyer, uint256 amount);

    constructor(BLSToken _blsToken, StakedBLSToken _stakedBLSToken) Ownable(msg.sender) {
        blsToken = _blsToken;
        stakedBLSToken = _stakedBLSToken;
    }

    // Purchase BLS tokens 
    // At the momemt user can but tokens without ether.
    function buyTokens( uint tokens) external payable {
        require(tokens > 0, "buy tokens should be greater thab0");
        blsToken.buyTokens(msg.sender, tokens);
        emit TokensPurchased(msg.sender, tokens);
    }

    // Stake BLS tokens to receive stBLS
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0 tokens");

        // Transfer BLS tokens from the user to the staking contract
        blsToken.transferToken(msg.sender,address(this),amount);

        // Mint equivalent stBLS tokens to the user
        stakedBLSToken.mint(msg.sender, amount);

        // Update the user's staked balance
        stakedBalances[msg.sender] += amount;

        emit Staked(msg.sender, amount);
    }

    // Unstake BLS tokens by burning stBLS
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0 tokens");
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");

        // Burn stBLS tokens from the user
        stakedBLSToken.burn(msg.sender, amount);

        // Transfer BLS tokens back to the user
        blsToken.transfer(msg.sender, amount);

        // Update the user's staked balance
        stakedBalances[msg.sender] -= amount;

        emit Unstaked(msg.sender, amount);
    }

    // Get staked balance of a user
    function stakedBalanceOf(address user) external view returns (uint256) {
        return stakedBalances[user];
    }
}
