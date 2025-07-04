pragma solidity ^0.8.0;

contract FixedAddressFinder {

    function computeAddress(address creator, uint256 nonce) public pure returns (address) {
        return address(uint160(keccak256(abi.encodePacked(creator, nonce))));
    }

    function destroyToken(address tokenAddress, address payable to) public {
        (bool success,) = tokenAddress.call(abi.encodeWithSignature("destroy(address payable)\