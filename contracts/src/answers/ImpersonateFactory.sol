// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IImpersonator {
    function owner() external view returns (address);
}

contract ImpersonateFactory {
    address public impersonator;
    
    constructor(address _impersonator) {
        impersonator = _impersonator;
    }
    
    // Maybe we need to deploy a contract at the factory address?
    // Or maybe we need to find a way to make our address look like the factory
    
    function getFactory() external view returns (address) {
        return IImpersonator(impersonator).owner();
    }
    
    // Try delegatecall to impersonate
    function tryDelegatecall() external returns (bool success) {
        (success, ) = impersonator.delegatecall(
            abi.encodeWithSignature("transferOwnership(address)", msg.sender)
        );
    }
}