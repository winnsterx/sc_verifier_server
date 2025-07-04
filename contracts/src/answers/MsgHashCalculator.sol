// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MsgHashCalculator {
    function calculateMsgHash(uint256 lockId) external pure returns (bytes32) {
        bytes32 _msgHash;
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1C, lockId)
            _msgHash := keccak256(0x00, 0x3c)
        }
        return _msgHash;
    }
    
    function getPrefix() external pure returns (bytes memory) {
        return "\x19Ethereum Signed Message:\n32";
    }
}