// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SignatureAnalyzer {
    
    function analyzeSignature(bytes memory _signature) external pure returns (bytes32 r, bytes32 s, uint8 v) {
        // Check how signature is laid out in memory
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }
    }
    
    function analyzeBuggyLoad(bytes memory _signature) external pure returns (bytes32 slot1, bytes32 slot2, bytes32 slot3) {
        // Mimic the buggy load pattern
        assembly {
            slot1 := mload(add(_signature, 0x60)) // Should be v but loads wrong data
            slot2 := mload(add(_signature, 0x20)) // Should be r
            slot3 := mload(add(_signature, 0x40)) // Should be s
        }
    }
    
    function computeMsgHash(uint256 lockId) external pure returns (bytes32) {
        bytes32 msgHash;
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1C, lockId)
            msgHash := keccak256(0x00, 0x3c)
        }
        return msgHash;
    }
    
    function testEcrecover(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) external pure returns (address) {
        return ecrecover(msgHash, v, r, s);
    }
}