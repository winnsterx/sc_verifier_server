pragma solidity ^0.8.0;

contract GasAttacker2 {
    uint256 public counter;

    fallback() external payable {
        // Use a state variable to prevent loop optimization
        while (true) {
            if (block.timestamp % 2 == 0) counter += 1;
            else break;
        }
    }
}