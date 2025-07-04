// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILevel {
    function validateInstance(address payable _instance, address _player) external view returns (bool);
}

contract DexWinConditionTester {
    // Try to understand what makes us win
    function checkWinCondition(address factory, address instance, address player) external view returns (bool) {
        try ILevel(factory).validateInstance(payable(instance), player) returns (bool result) {
            return result;
        } catch {
            return false;
        }
    }
}