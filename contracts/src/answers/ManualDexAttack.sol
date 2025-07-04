// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ManualDexAttack {
    // Simple contract to check if we can interact with the Dex
    function checkDex(address dex) external view returns (address token1, address token2) {
        // Try to read token addresses
        assembly {
            // token1 is at slot 1
            token1 := sload(1)
            // token2 is at slot 2  
            token2 := sload(2)
        }
    }
}