// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMagicNum {
    function setSolver(address) external;
}

contract SolverDeployer {
    address public solver;
    
    constructor(address target) {
        // Initialize code + runtime code
        // We need to deploy a contract that returns 42
        
        // Runtime code (what the contract will execute when called):
        // PUSH1 0x2a (42 in hex)  - 602a
        // PUSH1 0x00              - 6000  
        // MSTORE                  - 52
        // PUSH1 0x20              - 6020
        // PUSH1 0x00              - 6000
        // RETURN                  - f3
        // Runtime code: 0x602a60005260206000f3 (10 bytes)
        
        // Init code (constructor that returns the runtime code):
        // PUSH10 0x602a60005260206000f3 - 69602a60005260206000f3
        // PUSH1 0x00                    - 6000
        // MSTORE                        - 52
        // PUSH1 0x0a                    - 600a
        // PUSH1 0x16                    - 6016  
        // RETURN                        - f3
        // Init code: 0x69602a60005260206000f3600052600a6016f3 (19 bytes)
        
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address addr;
        
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        
        solver = addr;
        
        // Set the solver on the target contract
        IMagicNum(target).setSolver(solver);
    }
}