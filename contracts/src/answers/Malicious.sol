pragma solidity ^0.8.0;
contract Malicious {
    address private dummy1;
    address private dummy2;
    uint256 storedTime;

    function setTime(uint256 _time) public {
        storedTime = _time;
    }
}