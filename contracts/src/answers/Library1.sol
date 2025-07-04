pragma solidity ^0.8.0;
contract Library1 {
    function setTime(uint x) public {
        assembly {
            sstore(1, x)
        }
    }
}