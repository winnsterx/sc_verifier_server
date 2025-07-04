pragma solidity ^0.8.0;

contract ForceSend {
    function forceSend(address payable _target) public payable {
        selfdestruct(_target);
    }
}
