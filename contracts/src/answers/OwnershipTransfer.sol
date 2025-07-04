// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IOwnable {
    function transferOwnership(address newOwner) external;
    function owner() external view returns (address);
}

contract OwnershipTransfer {
    address constant FACTORY = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address constant INSTANCE = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    
    function transfer() external {
        // Since we own the factory, and the factory owns the instance,
        // we need to make the factory transfer ownership of the instance to us
        
        // First, let's encode the call to transferOwnership
        bytes memory data = abi.encodeWithSignature("transferOwnership(address)", msg.sender);
        
        // Call the factory to execute this on the instance
        (bool success,) = FACTORY.call(data);
        require(success, "Factory call failed");
    }
    
    function directTransfer() external {
        // Actually, since the factory owns the instance, 
        // we need to call the instance's transferOwnership from the factory context
        // But we can't do that directly...
        
        // Wait, we need to understand the factory contract better
        // It might have a function to transfer ownership of deployed contracts
    }
}