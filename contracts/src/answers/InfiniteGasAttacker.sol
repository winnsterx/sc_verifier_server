pragma solidity ^0.8.0;

contract InfiniteGasAttacker {
    uint256 public x;

    fallback() external payable {
        while (true) {
            x += 1;
        }
    }
}