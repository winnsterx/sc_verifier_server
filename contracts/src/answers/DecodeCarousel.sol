// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DecodeCarousel {
    function decode(uint256 value) external pure returns (address owner, uint16 nextId, uint80 animal) {
        owner = address(uint160(value & type(uint160).max));
        nextId = uint16((value >> 160) & type(uint16).max);
        animal = uint80((value >> 176) & type(uint80).max);
    }
}