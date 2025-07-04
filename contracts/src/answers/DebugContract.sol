// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DebugContract {
    function getCode(address addr) public view returns (bytes memory) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        bytes memory code = new bytes(size);
        assembly {
            extcodecopy(addr, add(code, 0x20), 0, size)
        }
        return code;
    }
    
    function getCodeSize(address addr) public view returns (uint256) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size;
    }
}