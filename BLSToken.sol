// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// BLS Token (ERC20) - Liquid staking token
contract BLSToken is ERC20{
    // constructor() ERC20("Blume Liquid Staking", "BLS") Ownable(msg.sender) {
    //     _mint(address(this), 1000); // Initial supply 
    // }

    constructor() ERC20("Blume Liquid Staking", "BLS") {
        _mint(address(this), 1000); // Initial supply 
    }

    // Buy BLS tokens 
    function buyTokens(address to, uint256 amount) external{
        require(balanceOf(address(this)) >= amount, "Not enough tokens in contract");
        transferToken(address(this), to, amount); 
    }

    //Transfer tokens
    function transferToken(address from, address to, uint amount) public  {
        _transfer(from, to, amount);
    }
}
