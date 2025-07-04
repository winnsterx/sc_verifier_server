// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FactoryChecker {
    function checkFactory(address factory) external view returns (bytes memory) {
        (bool success, bytes memory data) = factory.staticcall(
            abi.encodeWithSignature("validateInstance(address,address)", msg.sender, factory)
        );
        return data;
    }
    
    function callFunction(address target, string memory signature) external view returns (bool success, bytes memory data) {
        (success, data) = target.staticcall(abi.encodeWithSignature(signature));
    }
}