pragma solidity ^0.8.0;

contract ReentrancyFreeAttacker {
    address public kingTarget;

    constructor(address _kingTarget) {
        kingTarget = _kingTarget;
    }

    function attack() external payable {
        (bool success, ) = kingTarget.call{value: msg.value}('');
        require(success, "Attack failed");
    }

    receive() external payable {
        // Do nothing, just accept to avoid reentrancy issues
    }

    fallback() external payable {
        // Do nothing, just accept
    }
}