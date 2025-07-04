// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EncodingTest {
    function testEncoding(uint256 r, uint256 s, uint256 v) external pure returns (bytes memory, bytes32) {
        bytes memory encoded = abi.encode([r, s, v]);
        bytes32 hash = keccak256(encoded);
        return (encoded, hash);
    }
    
    function testEncodingSeparate(uint256 r, uint256 s, uint256 v) external pure returns (bytes memory, bytes32) {
        bytes memory encoded = abi.encode(r, s, v);
        bytes32 hash = keccak256(encoded);
        return (encoded, hash);
    }
    
    // Test if encoding an array literal produces different results
    function compareEncodings(bytes32 r, bytes32 s, uint8 v) external pure returns (bytes32 arrayHash, bytes32 separateHash, bool equal) {
        arrayHash = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]));
        separateHash = keccak256(abi.encode(uint256(r), uint256(s), uint256(v)));
        equal = (arrayHash == separateHash);
    }
}