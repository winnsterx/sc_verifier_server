// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DexInspector {
    function getCodeSize(address _addr) public view returns (uint256) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size;
    }
    
    function readSlot(address _addr, uint256 slot) public view returns (bytes32) {
        bytes32 value;
        assembly {
            value := sload(slot)
        }
        return value;
    }
}