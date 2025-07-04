pragma solidity ^0.8.0;

interface IInstance {
    function password() external view returns (string memory);
}

contract PasswordReader {
    function readPassword(address instance) public view returns (string memory) {
        return IInstance(instance).password();
    }
}