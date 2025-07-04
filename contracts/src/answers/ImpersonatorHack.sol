// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ImpersonatorHack {
    address public target;
    
    constructor(address _target) {
        target = _target;
    }
    
    // First, let's understand the contract layout
    // OpenZeppelin's Ownable in 0.8.x uses a specific storage slot
    function readOwnerSlot() external view returns (bytes32) {
        // OZ Ownable uses keccak256("eip1967.proxy.owner") - 1
        bytes32 slot = bytes32(uint256(keccak256("eip1967.proxy.owner")) - 1);
        bytes32 value;
        assembly {
            value := sload(slot)
        }
        return value;
    }
    
    // Try standard owner slot (0)
    function readSlot0() external view returns (address) {
        bytes32 value;
        assembly {
            value := sload(0)
        }
        return address(uint160(uint256(value)));
    }
    
    // The goal might be to take ownership
    // Let's see if we can call owner() directly through low-level call
    function tryGetOwner() external view returns (bool success, bytes memory data) {
        (success, data) = target.staticcall(abi.encodeWithSignature("owner()"));
    }
    
    function tryGetLockCounter() external view returns (bool success, bytes memory data) {
        (success, data) = target.staticcall(abi.encodeWithSignature("lockCounter()"));
    }
}