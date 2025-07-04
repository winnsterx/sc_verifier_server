pragma solidity ^0.8.0;

interface IInstance {
    function password() external view returns (string memory);
}

contract PasswordRevealer {
    IInstance public instance;

    constructor(address _instanceAddress) {
        instance = IInstance(_instanceAddress);
    }

    function revealPassword() external view returns (string memory) {
        return instance.password();
    }
}