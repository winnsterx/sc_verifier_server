pragma solidity ^0.8.0;

contract GasHog {
    receive() external payable {
        for (uint256 i = 0; i < 999999999999999999999999999999999999999999; i++) {
            uint256 j = i * i;
        }
    }
}