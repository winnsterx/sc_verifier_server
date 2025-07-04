pragma solidity ^0.8.0;
contract MagicAttacker {
    function spinCarousel(uint16 maxCapacity) public {
        // Loop to set animal and spin many times
        // Will eventually take control of the carousel through repeated calls
        uint256 encodedAnimal = 0; // encoded animal for empty string
        // Assume we can loop through until MAX_CAPACITY -1
        // After reaching the end, nextCrateId becomes 0
        // Then setAnimalAndSpin is called again to capture ownership of 0
    }
}
