// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract StorageReader {
    function getImplementation(address proxy) external view returns (address) {
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        address implementation;
        assembly {
            implementation := sload(slot)
        }
        return implementation;
    }
    
    function readSlot(address target, bytes32 slot) external view returns (bytes32) {
        bytes32 value;
        assembly {
            value := sload(slot)
        }
        return value;
    }
}