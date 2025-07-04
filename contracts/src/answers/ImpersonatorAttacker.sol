// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IImpersonator {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function deployNewLock(bytes memory signature) external;
}

interface IECLocker {
    function controller() external view returns (address);
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
}

contract ImpersonatorAttacker {
    address public immutable impersonator;
    address public immutable deployer;
    
    constructor(address _impersonator) {
        impersonator = _impersonator;
        deployer = msg.sender;
    }
    
    // Try to exploit the signature parsing vulnerability
    function attack() external {
        // The vulnerability is in how the constructor parses the signature
        // It expects: [32 bytes padding][32 bytes r][32 bytes s][32 bytes v]
        // But loads them in wrong order: v from 0x60, r from 0x20, s from 0x40
        
        // Let's create a malicious signature that will make ecrecover return address(0)
        // or a controllable address
        
        // First, let's try with a signature that would make ecrecover fail/return 0
        bytes memory maliciousSignature = new bytes(128);
        
        // The msgHash for lockId 1338 would be:
        // keccak256("\x19Ethereum Signed Message:\n32" + uint256(1338))
        
        // Set all bytes to 0 initially
        // This should make ecrecover return address(0) or fail
        
        // Try to deploy a lock with this signature
        try IImpersonator(impersonator).deployNewLock(maliciousSignature) {
            // If this works, we might have deployed a lock with controller = address(0)
        } catch {
            // If it fails, we need a different approach
        }
    }
    
    // Helper function to compute the message hash for a given lockId
    function computeMsgHash(uint256 lockId) public pure returns (bytes32) {
        bytes32 msgHash;
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1C, lockId)
            msgHash := keccak256(0x00, 0x3c)
        }
        return msgHash;
    }
    
    // Try to craft a signature that recovers to our address
    function attackWithCraftedSignature() external {
        // We need to understand the exact byte layout expected
        // The signature should be 128 bytes total
        bytes memory signature = new bytes(128);
        
        // Since v is loaded from offset 0x60 (96), r from 0x20 (32), s from 0x40 (64)
        // We need to place our signature components accordingly
        
        // First, let's try to make it recover to address(1) or another predictable address
        // We'll need to experiment with different values
        
        // Try deploying with various signatures
        IImpersonator(impersonator).deployNewLock(signature);
    }
}