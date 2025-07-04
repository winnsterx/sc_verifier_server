pragma solidity ^0.8.0;

contract AlienAttacker2 {
    function getOwnerBytes(address newOwner) public pure returns (bytes32) {
        // Pack the address into bytes32 for storage
        return bytes32(uint256(uint160(newOwner)));
    }
}