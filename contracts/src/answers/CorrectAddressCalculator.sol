pragma solidity ^0.8.0;

contract CorrectAddressCalculator {
    address private immutable _recoveryInstance;
    address public simpleTokenAddress;

    constructor(address recoveryAddress) {
        _recoveryInstance = recoveryAddress;
        bytes32 packed = keccak256(abi.encodePacked(bytes1(uint8(0xff)), _recoveryInstance, uint8(0x00)));
        simpleTokenAddress = address(uint160(packed));
    }

    function getSimpleToken() external view returns(address) {
        return simpleTokenAddress;
    }
}
