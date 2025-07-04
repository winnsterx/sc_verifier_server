pragma solidity ^0.8.0;

contract FixedMagicAttacker {
    
    function answer() public pure returns (bytes4) {
        return 0x634a46bf; // Correct function selector for address-based win check
    }

    constructor(address _instance) {
        _instance.setSolver(address(this));
    }
}