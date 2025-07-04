// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract StorageDecoder {
    uint256 constant ANIMAL_MASK = uint256(type(uint80).max) << 160 + 16;
    uint256 constant NEXT_ID_MASK = uint256(type(uint16).max) << 160;
    uint256 constant OWNER_MASK = uint256(type(uint160).max);
    
    function decodeCarouselEntry(uint256 entry) external pure returns (
        uint256 animal,
        uint256 nextId,
        address owner
    ) {
        owner = address(uint160(entry & OWNER_MASK));
        nextId = (entry & NEXT_ID_MASK) >> 160;
        animal = (entry & ANIMAL_MASK) >> (160 + 16);
    }
    
    function showMasks() external pure returns (uint256 animalMask, uint256 nextIdMask, uint256 ownerMask) {
        animalMask = ANIMAL_MASK;
        nextIdMask = NEXT_ID_MASK;
        ownerMask = OWNER_MASK;
    }
}