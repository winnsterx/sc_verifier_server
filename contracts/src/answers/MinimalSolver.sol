// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MinimalSolver {
    /* Compiler will not be used, inline assembly will be utilized for deploying minimal size bytecode. */
    constructor() {
        assembly {
            mstore(0x00, 0x602a60005260206000f3) // bytecode for `PUSH1 42 (0x2a)) PUSH1 0 PUSH1 0 MSTORE RETURN`
            return(0x00, 0x10) // 0x10 is arbitrary size larger than bytecode size
        }
    }
}