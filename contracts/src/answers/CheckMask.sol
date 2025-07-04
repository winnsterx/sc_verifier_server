// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract CheckMask {
    function getAnimalMask() external pure returns (uint256) {
        return uint256(type(uint80).max) << 160 + 16;
    }
    
    function getAnimalMaskCorrect() external pure returns (uint256) {
        return uint256(type(uint80).max) << (160 + 16);
    }
    
    function getExpectedAnimalMask() external pure returns (uint256) {
        return (uint256(type(uint80).max) << 160) + 16;
    }
}