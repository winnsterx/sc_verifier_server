// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract BugTest {
    function testBug(uint256 r, uint256 s, uint256 v) public pure returns (bytes32) {
        // This should not compile
        return keccak256(abi.encode([r, s, v]));
    }
    
    function testCorrect(uint256 r, uint256 s, uint256 v) public pure returns (bytes32) {
        // This is the correct way
        uint256[] memory arr = new uint256[](3);
        arr[0] = r;
        arr[1] = s;
        arr[2] = v;
        return keccak256(abi.encode(arr));
    }
}