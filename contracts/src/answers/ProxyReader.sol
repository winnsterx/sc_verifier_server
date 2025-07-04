// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract ProxyReader {
    function getStorageAt(address target, uint256 position) external view returns (bytes32) {
        bytes32 result;
        assembly {
            result := sload(position)
        }
        return result;
    }
    
    function getImplementationAddress(address proxy) external view returns (address) {
        // The implementation slot
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        bytes32 result;
        
        assembly {
            // Get proxy's code
            let freememstart := mload(0x40)
            let success := staticcall(gas(), proxy, 0, 0, freememstart, 0x20)
            
            // Load storage from proxy
            mstore(0x00, slot)
            success := staticcall(gas(), proxy, 0x00, 0x20, 0x00, 0x20)
            result := mload(0x00)
        }
        
        return address(uint160(uint256(result)));
    }
}