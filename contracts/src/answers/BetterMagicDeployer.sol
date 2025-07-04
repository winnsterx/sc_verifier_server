// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BetterMagicDeployer {
    address public lastDeployed;
    
    function deploy() public returns (address) {
        // The minimal bytecode that returns 42:
        // Runtime code: 602a60805260206080f3 (10 bytes)
        
        bytes memory bytecode = hex"600a600c600039600a6000f3602a60805260206080f3";
        
        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(addr != address(0), "Failed to deploy");
        lastDeployed = addr;
        return addr;
    }
    
    function getLastDeployed() public view returns (address) {
        return lastDeployed;
    }
}