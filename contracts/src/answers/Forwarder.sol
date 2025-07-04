pragma solidity ^0.8.0;

interface IDelegate {
    function pwn() external;
}

contract Forwarder {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function forwardPwn() external {
        IDelegate(target).pwn();
    }
}