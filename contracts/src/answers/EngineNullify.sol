// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EngineNullify {
    // Null constructor
    constructor() public { }

    function invalidate() external {
        selfdestruct(payable(msg.sender)); // Intentionally causes the EVM to mark implementation as invalid
    }
}