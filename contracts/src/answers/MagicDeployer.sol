// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MagicDeployer {
    function deploy() public returns (address) {
        // The minimal bytecode that returns 42:
        // Runtime code: 602a60805260206080f3
        // 0x60 0x2a - PUSH1 42
        // 0x60 0x80 - PUSH1 0x80 (memory position)
        // 0x52 - MSTORE
        // 0x60 0x20 - PUSH1 32 (return size)
        // 0x60 0x80 - PUSH1 0x80 (memory position)
        // 0xf3 - RETURN
        
        bytes memory bytecode = hex"600a600c600039600a6000f3602a60805260206080f3";
        
        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(addr != address(0), "Failed to deploy");
        return addr;
    }
}