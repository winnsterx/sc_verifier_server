// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IFactory {
    function validateInstance(address payable _instance, address _player) external view returns (bool);
}

contract WinConditionChecker {
    function checkWinCondition(address factory, address instance, address player) external view returns (bool, bytes memory) {
        // Call validateInstance to see what the win condition is
        try IFactory(factory).validateInstance(payable(instance), player) returns (bool result) {
            return (result, "");
        } catch Error(string memory reason) {
            return (false, bytes(reason));
        } catch (bytes memory data) {
            return (false, data);
        }
    }
}