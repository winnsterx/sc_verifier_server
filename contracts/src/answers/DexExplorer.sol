// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDexFactory {
    function validateInstance(address payable _instance, address _player) external view returns (bool);
    function createInstance(address _player) external payable returns (address);
}

contract DexExplorer {
    function checkFactory(address factory, address instance, address player) public view returns (bool) {
        try IDexFactory(factory).validateInstance(payable(instance), player) returns (bool result) {
            return result;
        } catch {
            return false;
        }
    }
    
    function tryCreateInstance(address factory) public returns (address) {
        return IDexFactory(factory).createInstance(msg.sender);
    }
}