pragma solidity ^0.8.0;
contract FirstMalicious {
    uint256 storedTime;
    function setTime(uint256 _timeStamp) public {
        storedTime = _timeStamp;
    }
}
