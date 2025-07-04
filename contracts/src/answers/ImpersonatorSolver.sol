// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../levels/Impersonator.sol";

contract ImpersonatorSolver {
    Impersonator public impersonator;
    ECLocker public locker;
    address public deployer;
    
    constructor(address _impersonator, address _locker) {
        impersonator = Impersonator(_impersonator);
        locker = ECLocker(_locker);
        deployer = msg.sender;
    }
    
    // The key insight: if the Impersonator owner is the factory,
    // and we become the owner, we've "impersonated" the factory!
    
    function solve() external {
        // We need to find a way to make the factory transfer ownership
        // Or find a way to bypass the onlyOwner modifier
        
        // What if the vulnerability is in how modifiers work?
        // What if we can somehow call transferOwnership through the ECLocker?
        
        // Let's check if the factory has any special relationship with the locker
        address factory = impersonator.owner();
        address controller = locker.controller();
        
        // Try to exploit through the locker somehow
        // The bug in _isValidSignature might allow us to do something unexpected
    }
    
    // What if we need to be called BY the impersonator/factory?
    fallback() external {
        // If we're called, try to transfer ownership
        if (msg.sender == address(impersonator) || msg.sender == impersonator.owner()) {
            impersonator.transferOwnership(deployer);
        }
    }
}