// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IInstance {
    function authenticate(string memory passkey) external;
}

contract PasswordRetriever {
    IInstance public instance;

    constructor(address _instanceAddress) {
        instance = IInstance(_instanceAddress);
    }

    function retrievePassword() public view returns (string memory) {
        // Assuming the password is stored in slot 0 based on storage order
        bytes32 slot0;

        assembly {
            slot0 := sload(0)
        }

        return abi.decode(abi.encodePacked(slot0), (string));
    }

    function authenticate() public {
        string memory password = retrievePassword();
        instance.authenticate(password);
    }
}