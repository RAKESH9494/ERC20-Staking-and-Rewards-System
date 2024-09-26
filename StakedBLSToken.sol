// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Staked BLS Token (stBLS) - Token users receive when they stake BLS
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
