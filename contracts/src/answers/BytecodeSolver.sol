// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISolver {
    function whatIsTheMeaningOfLife() external pure returns (uint);
}

contract BytecodeSolver {
    function deployBytecode(bytes calldata bytecode) external returns (address) {
        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        return addr;
    }
}