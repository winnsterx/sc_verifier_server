// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract ProxyStorageReader {
    function readImplementation(address proxy) external returns (address) {
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        bytes memory encodedCall = abi.encodeWithSignature("getImplementation()");
        
        // Deploy a helper contract with the bytecode that reads the slot
        bytes memory bytecode = abi.encodePacked(
            hex"608060405234801561001057600080fd5b5073",
            proxy,
            hex"7f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc5460005260206000f3"
        );
        
        address reader;
        assembly {
            reader := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        
        (bool success, bytes memory result) = reader.staticcall("");
        require(success, "Failed to read");
        
        return abi.decode(result, (address));
    }
    
    function simpleRead(address target) external view returns (bytes32) {
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        
        (bool success, bytes memory data) = target.staticcall(
            abi.encodeWithSelector(bytes4(keccak256("sload(uint256)")), uint256(slot))
        );
        
        if (success && data.length > 0) {
            return abi.decode(data, (bytes32));
        }
        
        // Try raw call
        assembly {
            let result := staticcall(gas(), target, 0, 0, 0, 0x20)
            if result {
                returndatacopy(0, 0, 0x20)
                return(0, 0x20)
            }
        }
        
        return bytes32(0);
    }
}