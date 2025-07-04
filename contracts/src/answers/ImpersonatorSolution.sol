// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IECLocker {
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
    function controller() external view returns (address);
    function msgHash() external view returns (bytes32);
    function usedSignatures(bytes32) external view returns (bool);
}

contract ImpersonatorSolution {
    IECLocker constant locker = IECLocker(0x8Ff3801288a85ea261E4277d44E1131Ea736F77B);
    address constant currentController = 0x42069d82D9592991704e6E41BF2589a76eAd1A91;
    
    function attack() external {
        // The vulnerability is that the signature validation computes:
        // signatureHash = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]))
        // But this encodes a dynamic array, not three values
        
        // The goal is to find r,s,v such that ecrecover returns currentController
        // but the signatureHash hasn't been used
        
        // Since we don't have the private key, we need to exploit edge cases
        // or find a way to make ecrecover return the correct address
        
        // One approach: signature malleability
        // For any valid signature (v,r,s), there's another valid signature (v',r,s')
        // where s' = n - s (mod n) and v' = v ^ 1
        
        // But we need the original signature first...
        
        // Alternative approach: exploit the array encoding bug
        // Maybe we can find two different (r,s,v) tuples that when encoded as arrays,
        // produce the same hash
        
        // Let's try some edge cases where ecrecover might behave unexpectedly
        
        // Edge case: v = 0 (invalid for standard ECDSA)
        tryExploit(0, bytes32(uint256(1)), bytes32(uint256(1)));
        
        // Edge case: Large v values
        for (uint8 i = 0; i < 255; i++) {
            if (tryExploit(i, bytes32(uint256(1)), bytes32(uint256(1)))) {
                return;
            }
        }
    }
    
    function tryExploit(uint8 v, bytes32 r, bytes32 s) internal returns (bool) {
        // First check if this signature hash has been used
        uint256[] memory arr = new uint256[](3);
        arr[0] = uint256(r);
        arr[1] = uint256(s);
        arr[2] = uint256(v);
        bytes32 sigHash = keccak256(abi.encode(arr));
        
        if (locker.usedSignatures(sigHash)) {
            return false;
        }
        
        // Check what address ecrecover returns
        bytes32 msgHash = locker.msgHash();
        address recovered = ecrecover(msgHash, v, r, s);
        
        if (recovered == currentController) {
            // Found it! Change the controller
            locker.changeController(v, r, s, msg.sender);
            return true;
        }
        
        return false;
    }
    
    // Let's also try to compute what the msgHash should be
    function computeMsgHash() public pure returns (bytes32) {
        bytes32 msgHash;
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1C, 1337) // lockId
            msgHash := keccak256(0x00, 0x3c)
        }
        return msgHash;
    }
}