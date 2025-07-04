pragma solidity ^0.7.0;

/*
This contract simply returns 42 when called, and takes advantage of a
minimalist approach to deploy the exact specified EVM bytecode.
*/

contract MinimalistSolver {
    constructor() {
        assembly {
            // Runtime: 602a60005260206000f3
            // Explanation:
            // PUSH1 0x2A    // Push 42
            // PUSH1 0x00    // Store at memory position 0
            // MSTORE        // Store 42 at position 0
            // PUSH1 0x20    // Length of return data
            // PUSH1 0x00    // Point to memory start
            // RETURN        // Return memory contents
            mstore(0x00, hex"602a60005260206000f3")
            return(0x00, 0x0a)  // return code (10 bytes generated)
        }
    }
}