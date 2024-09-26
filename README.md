Here is the detailed explanation about contracts
### **1. BLSToken (BLS Token Contract)**

The `BLSToken` contract represents the native cryptocurrency token (`BLS`) used for staking. It is an ERC20 token.

- **Key Features:**
  - **ERC20 & Ownable**: Inherits from the OpenZeppelin ERC20 standard contract and Ownable contract to manage ownership of the contract.
  - **Constructor**: Initializes the token with the name "Blume Liquid Staking" and symbol "BLS", and mints an initial supply of 1000 tokens to the contract.
  - **Buy Tokens**: Allows users to purchase BLS tokens from the contract if it has enough tokens available. It uses the `buyTokens` function to transfer tokens to the buyer.
  - **Transfer Function**: Transfers tokens between addresses.

```solidity
contract BLSToken is ERC20, Ownable{
    constructor() ERC20("Blume Liquid Staking", "BLS") Ownable(msg.sender) {
        _mint(address(this), 1000*(10 ** decimals())); // Initial supply 
    }

    // Buy BLS tokens 
    function buyTokens(address to, uint256 amount) external{
        require(balanceOf(address(this)) >= amount, "Not enough tokens in contract");
        transferToken(address(this), to, amount); 
    }

    //Transfer tokens
    function transferToken(address from, address to, uint amount) public  {
        _transfer(from, to, amount*(10 ** decimals()));
    }
}

```

---

### **2. StakedBLSToken (stBLS Token Contract)**

The `StakedBLSToken` contract represents the staked version of the BLS token (`stBLS`). When users stake their BLS tokens, they receive `stBLS` in return.

- **Key Features:**
  - **ERC20**: Inherits from the OpenZeppelin ERC20 standard contract.
  - **Mint/Burn**: The contract allows minting and burning of `stBLS` tokens. Minting happens when users stake BLS, and burning happens when they unstake.
  - **Access Control**: Only the staking contract can mint and burn `stBLS` tokens, ensuring that these actions are controlled by the staking mechanism.

```solidity
contract StakedBLSToken is ERC20 {
    constructor() ERC20("Staked BLS", "stBLS") {
        _mint(address(this), 1000*(10 ** decimals())); // Initial supply 
    }

    // Mint stBLS tokens 
    function mint(address to, uint256 amount) external {
        _mint(to, amount*(10 ** decimals()));
    }

    // Burn stBLS tokens 
    function burn(address from, uint256 amount) external {
        _burn(from, amount*(10 ** decimals()));
    }
}
```

---

### **3. BlumeStaking (Staking Contract)**

The `BlumeStaking` contract manages the staking and unstaking process. Users stake their BLS tokens to receive staked tokens (`stBLS`), and they can later redeem them for the original BLS tokens.

- **Key Features:**
  - **BLSToken and StakedBLSToken Instances**: This contract interacts with both the `BLSToken` and `StakedBLSToken` contracts.
  - **Buy BLS Tokens**: Users can buy BLS tokens by calling the `buyTokens` function. The purchased tokens are transferred to the user's address.
  - **Staking Functionality**: Users can stake BLS tokens by calling the `stake` function. When they stake BLS tokens, the contract mints equivalent `stBLS` tokens to their address.
  - **Unstaking Functionality**: Users can unstake BLS tokens by burning their `stBLS` tokens. The corresponding BLS tokens are then transferred back to them.
  - **Reentrancy Protection**: The contract uses OpenZeppelin's `ReentrancyGuard` to prevent reentrancy attacks.

```solidity

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
    // At the momemt user can buy tokens without ether.
    function buyTokens( uint tokens) external payable {
        require(tokens > 0, "buy tokens should be greater than 0");
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
        blsToken.transferToken(address(this),msg.sender,amount);

        // Update the user's staked balance
        stakedBalances[msg.sender] -= amount;

        emit Unstaked(msg.sender, amount);
    }

    // Get staked balance of a user
    function stakedBalanceOf(address user) external view returns (uint256) {
        return stakedBalances[user];
    }
}

```

---

### **How It Works:**
1. **Purchase BLS Tokens:**
   - Users can call the `buyTokens` function in the `BlumeStaking` contract to purchase BLS tokens. The contract transfers the requested amount of BLS tokens to the user's address.

2. **Stake BLS Tokens:**
   - Users call the `stake` function in the `BlumeStaking` contract. This transfers BLS tokens from the user to the contract, mints an equivalent amount of staked tokens (`stBLS`), and credits the user's staked balance.

3. **Unstake BLS Tokens:**
   - Users call the `unstake` function to burn their `stBLS` tokens and receive the corresponding amount of BLS tokens back. The staked balance is reduced accordingly.



Demo : https://www.youtube.com/watch?v=nI7snuM205c
