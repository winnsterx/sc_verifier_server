pragma solidity ^0.8.0;

interface IFactory {
    function submitSolution(address _instance) external;
}

contract FactoryAttacker {
    address public factoryAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    
    function invokeFactory(address _instance) public {
        IFactory(factoryAddress).submitSolution(_instance);
    }
}