pragma solidity ^0.8.0;

contract GasAttacker {
    
    fallback() external {
        // Consume excessive gas in a loop
        uint i = 0;
        while (i < 100000) {
            i++;
        }
    }
}