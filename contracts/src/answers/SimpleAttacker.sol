// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SimpleAttacker {
    // The target locker address
    address constant LOCKER = 0x8Ff3801288a85ea261E4277d44E1131Ea736F77B;
    
    // Current controller from our check
    address constant CURRENT_CONTROLLER = 0x42069d82D9592991704e6E41BF2589a76eAd1A91;
    
    function attack() external {
        // The vulnerability is in the signature validation
        // Since abi.encode([uint256(r), uint256(s), uint256(v)]) encodes a dynamic array
        // The signature hash will be different than expected
        
        // We need to find r, s, v such that:
        // 1. ecrecover(msgHash, v, r, s) == CURRENT_CONTROLLER
        // 2. The signature hash hasn't been used
        
        // Since we don't have the private key of CURRENT_CONTROLLER,
        // we need to exploit the flaw in signature validation
        
        // The msgHash for lockId 1337
        bytes32 msgHash;
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 28 bytes
            mstore(0x1C, 1337) // 32 bytes (lockId)
            msgHash := keccak256(0x00, 0x3c) //28 + 32 = 60 bytes
        }
        
        // Try to find a collision or exploit the encoding bug
        // Since the signature validation is flawed, maybe we can use
        // special values that cause unexpected behavior
        
        // Let's try with v = 0 which is invalid for ECDSA but might cause issues
        uint8 v = 0;
        bytes32 r = bytes32(uint256(1));
        bytes32 s = bytes32(uint256(1));
        
        // Call changeController
        (bool success,) = LOCKER.call(
            abi.encodeWithSignature(
                "changeController(uint8,bytes32,bytes32,address)",
                v, r, s, msg.sender
            )
        );
        
        if (!success) {
            // Try with other edge cases
            v = 1;
            (success,) = LOCKER.call(
                abi.encodeWithSignature(
                    "changeController(uint8,bytes32,bytes32,address)",
                    v, r, s, msg.sender
                )
            );
        }
    }
    
    // Alternative approach: exploit array encoding
    function attackWithArrayEncoding() external {
        // The flaw is that signatureHash = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]))
        // This encodes a dynamic array, not three values
        
        // Maybe we can find two different (v,r,s) tuples that produce the same array encoding
        // Or exploit some edge case in the encoding
        
        // Actually, wait! The ecrecover might return address(0) for invalid signatures
        // And if controller was set to address(0) somehow...
        
        // Let me check if we can make ecrecover return the current controller
        // with carefully crafted values
    }
}