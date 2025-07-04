// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BytecodeChecker {
    function getCodeSize(address addr) external view returns (uint256) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size;
    }
}