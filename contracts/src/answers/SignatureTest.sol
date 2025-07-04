// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SignatureTest {
    function testEncode(uint256 r, uint256 s, uint256 v) public pure returns (bytes memory) {
        // This is what the vulnerable contract tries to do
        return abi.encode([r, s, v]);
    }
    
    function testEncodeProper(uint256 r, uint256 s, uint256 v) public pure returns (bytes memory) {
        // This is the proper way
        return abi.encode(r, s, v);
    }
    
    function testHash(uint256 r, uint256 s, uint256 v) public pure returns (bytes32) {
        // This is what the vulnerable contract does
        return keccak256(abi.encode([r, s, v]));
    }
}