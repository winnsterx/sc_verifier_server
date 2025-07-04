pragma solidity ^0.8.28;

interface Impersonator {
    function deployNewLock(bytes calldata signature) external;
}

contract ECLockerAttacker {
    address instance;
    address owner;

    constructor(address _instance, address _owner) {
        instance = _instance;
        // Example attack logic (requires signature forgery)
    }

    function sendMalformedSig() external {
        bytes memory signature = abi.encodePacked(
            bytes32(0x00),
            bytes32(0x00),
            0x1c // 28 in hex
        );
        Impersonator(instance).deployNewLock(signature);
    }
}
