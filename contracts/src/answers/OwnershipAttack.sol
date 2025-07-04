// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IImpersonator {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}

contract OwnershipAttack {
    IImpersonator public impersonator;
    address public deployer;
    
    constructor(address _impersonator) {
        impersonator = IImpersonator(_impersonator);
        deployer = msg.sender;
    }
    
    function checkOwner() external view returns (address) {
        return impersonator.owner();
    }
    
    function tryTransfer() external {
        // Maybe we need to impersonate the owner somehow
        impersonator.transferOwnership(deployer);
    }
}