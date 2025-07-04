pragma solidity ^0.8.0;

contract MagicNumSolver {
    constructor() {
        assembly {
            let ptr := mload(0x40)

            // Store the bytecode of the deployable contract (which simply returns 42 when called)
            // Bytecode to push 42 onto the stack and return
            mstore(ptr, 0x602a60505260206050f3)
            
            // Return the memory area starting from this pointer (ptr) and having length (10 bytes)
            return(ptr, 10)
        }
    }
}
