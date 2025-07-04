pragma solidity ^0.8.0;

contract HackContract {
    function setImplementation(bytes32 slot, address newImpl) external {
        assembly {
            sstore(slot, newImpl)
        }
    }
}