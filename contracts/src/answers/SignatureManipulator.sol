// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IECLocker {
    function controller() external view returns (address);
    function msgHash() external view returns (bytes32);
    function lockId() external view returns (uint256);
    function usedSignatures(bytes32) external view returns (bool);
    function open(uint8 v, bytes32 r, bytes32 s) external;
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
}

contract SignatureManipulator {
    // The bug is that the contract uses abi.encode([r,s,v]) instead of abi.encode(r,s,v)
    // This means we can create different (v,r,s) tuples that hash to the same value!
    
    function findCollision() external pure returns (
        uint8 v1, bytes32 r1, bytes32 s1,
        uint8 v2, bytes32 r2, bytes32 s2
    ) {
        // Since abi.encode([uint256(r), uint256(s), uint256(v)]) encodes an array,
        // the encoding includes array metadata
        
        // For a dynamic array, the encoding is:
        // - offset to array data (32 bytes) = 0x20
        // - array length (32 bytes) = 3
        // - array elements (32 bytes each) = r, s, v
        
        // This means the actual bytes being hashed are predictable
        // and we might be able to find collisions or manipulate the encoding
        
        // Let's try some values
        v1 = 27;
        r1 = bytes32(uint256(1));
        s1 = bytes32(uint256(2));
        
        // Due to the array encoding bug, these might produce the same hash
        // if we carefully craft them
        v2 = 28; 
        r2 = bytes32(uint256(1));
        s2 = bytes32(uint256(2));
        
        // Actually, let me think about this differently...
        // The encoding will be the same only if all values are the same
        // But wait - the bug is more subtle
    }
    
    function getArrayEncoding(uint256 r, uint256 s, uint256 v) external pure returns (bytes memory) {
        return abi.encode([uint256(r), uint256(s), uint256(v)]);
    }
    
    function getProperEncoding(uint256 r, uint256 s, uint256 v) external pure returns (bytes memory) {
        return abi.encode(r, s, v);
    }
    
    function exploitLocker(address locker) external {
        // Get the msgHash and controller
        bytes32 msgHash = IECLocker(locker).msgHash();
        address currentController = IECLocker(locker).controller();
        
        // The vulnerability is complex - we need to either:
        // 1. Find a valid signature for the current controller
        // 2. Exploit the signature parsing in the constructor
        // 3. Exploit the array encoding bug in signature validation
        
        // Since we don't have the private key of the controller,
        // we need to exploit the implementation bugs
    }
    
    // Helper to compute what the msgHash should be for a lockId
    function computeMsgHash(uint256 lockId) external pure returns (bytes32) {
        bytes32 msgHash;
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1C, lockId)
            msgHash := keccak256(0x00, 0x3c)
        }
        return msgHash;
    }
}