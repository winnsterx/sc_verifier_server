pragma solidity ^0.8.0;

contract NewImplementation {
    address public upgrader;

    function setNewImplementation(address newImpl) external {
        // Allows upgrader to set new implementation
    }

    function setHorsePower(uint256 newHorsePower) external {
        // Allows upgrader to modify horsePower
    }
}