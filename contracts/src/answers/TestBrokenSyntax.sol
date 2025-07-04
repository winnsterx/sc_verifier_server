// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract TestBrokenSyntax {
    function testEncoding(uint256 r, uint256 s, uint256 v) public pure returns (bytes32) {
        // This should fail to compile or behave unexpectedly
        // return keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]));
        
        // Let's test what might happen - the compiler might interpret it as:
        // 1. A memory pointer to an array
        // 2. Just encode the first value
        // 3. Something else
        
        // Actually, in newer Solidity, inline array syntax might work differently
        // Let's try to simulate possible outcomes
        
        // Option 1: It might encode a dynamic array
        uint256[] memory arr = new uint256[](3);
        arr[0] = r;
        arr[1] = s;
        arr[2] = v;
        return keccak256(abi.encode(arr));
    }
    
    function testEncoding2(uint256 r, uint256 s, uint256 v) public pure returns (bytes32) {
        // Option 2: It might just fail and return a constant
        return keccak256(abi.encode(r, s, v));
    }
    
    function testActualBroken() public pure returns (bytes memory) {
        uint256 r = 1;
        uint256 s = 2;
        uint256 v = 3;
        
        // Simulate what the broken syntax might produce
        // The array literal syntax in abi.encode context is problematic
        return "";
    }
}