// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract StorageExplorer {
    function getArraySlot(uint256 baseSlot) external pure returns (bytes32) {
        return keccak256(abi.encode(baseSlot));
    }
    
    function getSlotAsUint(bytes32 slot) external pure returns (uint256) {
        return uint256(slot);
    }
}