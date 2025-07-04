// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ArrayBugTester {
    function testArrayEncoding() external pure returns (bytes memory, bytes memory, bytes memory, bytes memory) {
        uint256 r = 0x1111111111111111111111111111111111111111111111111111111111111111;
        uint256 s = 0x2222222222222222222222222222222222222222222222222222222222222222;
        uint256 v = 27;
        
        // Test different encodings
        bytes memory encoding1 = abi.encode([uint256(r), uint256(s), uint256(v)]);
        bytes memory encoding2 = abi.encode([r, s, v]);
        
        // Compare with proper array
        uint256[3] memory properArray = [r, s, v];
        bytes memory encoding3 = abi.encode(properArray);
        
        // And with dynamic array
        uint256[] memory dynArray = new uint256[](3);
        dynArray[0] = r;
        dynArray[1] = s;
        dynArray[2] = v;
        bytes memory encoding4 = abi.encode(dynArray);
        
        return (encoding1, encoding2, encoding3, encoding4);
    }
    
    function getHashes() external pure returns (bytes32, bytes32, bytes32, bytes32) {
        uint256 r = 0x1111111111111111111111111111111111111111111111111111111111111111;
        uint256 s = 0x2222222222222222222222222222222222222222222222222222222222222222;
        uint256 v = 27;
        
        bytes32 hash1 = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]));
        
        uint256[3] memory properArray = [r, s, v];
        bytes32 hash2 = keccak256(abi.encode(properArray));
        
        uint256[] memory dynArray = new uint256[](3);
        dynArray[0] = r;
        dynArray[1] = s; 
        dynArray[2] = v;
        bytes32 hash3 = keccak256(abi.encode(dynArray));
        
        // What if the array literal creates a fixed array?
        bytes32 hash4 = keccak256(abi.encode([r, s, v]));
        
        return (hash1, hash2, hash3, hash4);
    }
}