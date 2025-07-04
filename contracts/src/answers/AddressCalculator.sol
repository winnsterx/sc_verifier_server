pragma solidity ^0.8.0;

contract AddressCalculator {
    address private immutable _recoveryInstance;
    address public simpleTokenAddress;

    constructor(address recoveryAddress, uint8 nonce) {
        _recoveryInstance = recoveryAddress;
        bytes32 packed = keccak256(abi.encodePacked(recoveryAddress, uint256(nonce)));
        uint256 hash = uint256(packed);
        simpleTokenAddress = address(uint160(hash >> 96));
    }

    function getSimpleToken() external view returns(address) {
        return simpleTokenAddress;
    }
}
