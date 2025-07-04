// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IECLocker {
    function controller() external view returns (address);
    function lockId() external view returns (uint256);
    function msgHash() external view returns (bytes32);
    function usedSignatures(bytes32) external view returns (bool);
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
    function open(uint8 v, bytes32 r, bytes32 s) external;
}

contract ECLockerAttack {
    IECLocker constant TARGET = IECLocker(0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968);
    
    function getState() external view returns (
        address controller,
        uint256 lockId,
        bytes32 msgHash
    ) {
        controller = TARGET.controller();
        lockId = TARGET.lockId();
        msgHash = TARGET.msgHash();
    }
    
    // The vulnerability: _isValidSignature uses
    // keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]))
    // instead of keccak256(abi.encodePacked(r, s, v))
    
    // This means the hash includes array encoding metadata!
    function showArrayEncoding(bytes32 r, bytes32 s, uint8 v) external pure returns (bytes memory encoded, bytes32 hash) {
        uint256[3] memory arr = [uint256(r), uint256(s), uint256(v)];
        encoded = abi.encode(arr);
        hash = keccak256(encoded);
    }
    
    // The goal is to change the controller to us
    // We need a valid signature from the current controller
    // But the buggy hash calculation might allow us to bypass this!
}