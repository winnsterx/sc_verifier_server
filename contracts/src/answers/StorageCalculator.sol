pragma solidity ^0.5.0;

contract StorageCalculator {
    function calculateIndex() public pure returns (uint256) {
        // Calculate where the array data starts
        bytes32 arrayDataStart = keccak256(abi.encode(uint256(1)));
        
        // To wrap around to slot 0, we need:
        // arrayDataStart + index = 2^256 (which wraps to 0)
        // So: index = 2^256 - arrayDataStart
        
        // Since we're in uint256, this naturally handles the modulo
        uint256 index = uint256(-1) - uint256(arrayDataStart) + 1;
        
        return index;
    }
}