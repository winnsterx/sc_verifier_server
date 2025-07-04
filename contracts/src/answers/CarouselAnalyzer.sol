// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract CarouselAnalyzer {
    function analyzeShifts() external pure returns (uint256 shift1, uint256 shift2, uint256 shift3) {
        // In setAnimalAndSpin: encodedAnimal << 160 + 16
        // Due to precedence: encodedAnimal << (160 + 16) = encodedAnimal << 176
        shift1 = 160 + 16; // = 176
        
        // In changeAnimal: encodedAnimal << 160
        shift2 = 160;
        
        // The difference is 16 bits
        shift3 = shift1 - shift2;
    }
    
    function testEncoding(string calldata animal) external pure returns (uint256 encoded, uint256 shiftedBy176, uint256 shiftedBy160) {
        encoded = uint256(bytes32(abi.encodePacked(animal)) >> 160);
        shiftedBy176 = encoded << 176;
        shiftedBy160 = encoded << 160;
    }
}