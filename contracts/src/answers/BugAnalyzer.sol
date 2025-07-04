// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract BugAnalyzer {
    // Test what happens with the array encoding
    function analyzeEncoding(uint256 r, uint256 s, uint256 v) public pure returns (bytes memory encoded, bytes32 hash) {
        encoded = abi.encode([r, s, v]);
        hash = keccak256(encoded);
    }
    
    // Test if we can create collisions
    function findCollision() public pure returns (bool) {
        // Test case 1: Same values, different order
        bytes32 h1 = keccak256(abi.encode([uint256(1), uint256(2), uint256(3)]));
        bytes32 h2 = keccak256(abi.encode([uint256(2), uint256(1), uint256(3)]));
        
        // Test case 2: Different representations
        bytes32 h3 = keccak256(abi.encode([uint256(1), uint256(2), uint256(3)]));
        uint256[3] memory arr = [uint256(1), uint256(2), uint256(3)];
        bytes32 h4 = keccak256(abi.encode(arr));
        
        return h3 == h4; // Should be true
    }
    
    // The actual attack vector might be that we can predict valid signatures
    // that haven't been used yet
    function computeSignatureHash(uint256 r, uint256 s, uint256 v) public pure returns (bytes32) {
        return keccak256(abi.encode([r, s, v]));
    }
}