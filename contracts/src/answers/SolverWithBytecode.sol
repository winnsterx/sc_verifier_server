// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SolverWithBytecode {
    address public solver;

    function setSolver() public {
        // Inline assembly to deploy a simple contract that returns 42
        bytes32 runtimeCodeHash;
        address runtimeAddress;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"602a60005260206000f3")
            runtimeAddress := create(0, ptr, 9)
            runtimeCodeHash := extcodehash(runtimeAddress)
        }
        solver = runtimeAddress;
    }
}