pragma solidity ^0.8.0;

interface IECLocker {
    function msgHash() external view returns (bytes32);
    function usedSignatures(bytes32) external view returns (bool);
}

contract LockerHelper {
    function getEmptyArrayHash() external pure returns (bytes32) {
        uint256[] memory empty = new uint256[](0);
        return keccak256(abi.encode(empty));
    }
    
    function checkIfUsed(address locker) external view returns (bool) {
        uint256[] memory empty = new uint256[](0);
        bytes32 emptyHash = keccak256(abi.encode(empty));
        return IECLocker(locker).usedSignatures(emptyHash);
    }
    
    function getMsgHash(address locker) external view returns (bytes32) {
        return IECLocker(locker).msgHash();
    }
}