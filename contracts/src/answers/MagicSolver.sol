pragma solidity ^0.8.0;

contract MagicSolver {
    fallback() external {
        assembly {
            mstore(0x00, 0x213a31) // Store magic bytes at memory 0
            return(0x00, 4) // Return first 4 bytes
        }
    }
}