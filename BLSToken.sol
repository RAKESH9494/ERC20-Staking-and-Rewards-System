// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// BLS Token (ERC20) - Liquid staking token
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
