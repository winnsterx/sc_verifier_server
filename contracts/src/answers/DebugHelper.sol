// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DebugHelper {
    // Try to understand the Dex state
    function debugDex(address dex) public view returns (
        bool hasCode,
        address owner,
        bytes memory token1CallResult,
        bytes memory token2CallResult
    ) {
        // Check if address has code
        uint256 size;
        assembly {
            size := extcodesize(dex)
        }
        hasCode = size > 0;
        
        // Try to get owner (slot 0 for Ownable)
        bytes32 ownerSlot;
        assembly {
            ownerSlot := sload(0)
        }
        owner = address(uint160(uint256(ownerSlot)));
        
        // Try to call token1 and token2
        bool success1;
        bool success2;
        (success1, token1CallResult) = dex.staticcall(abi.encodeWithSignature("token1()"));
        (success2, token2CallResult) = dex.staticcall(abi.encodeWithSignature("token2()"));
    }
    
    // Read multiple storage slots
    function readSlots(address target, uint256 startSlot, uint256 numSlots) public view returns (bytes32[] memory) {
        bytes32[] memory values = new bytes32[](numSlots);
        for (uint256 i = 0; i < numSlots; i++) {
            assembly {
                let slot := add(startSlot, i)
                values[i] := sload(slot)
            }
        }
        return values;
    }
}