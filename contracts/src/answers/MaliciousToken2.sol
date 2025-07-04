// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

contract MaliciousToken2 is ERC20 {
    constructor() ERC20("Malicious2", "MAL2") {
        // Mint tokens to ourselves
        _mint(msg.sender, 1000);
    }
    
    // Allow anyone to approve
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
}