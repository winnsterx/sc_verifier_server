// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EngineSelfDestruct {
    function execute() external {
        selfdestruct(payable(msg.sender));
    }
}