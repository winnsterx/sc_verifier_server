pragma solidity ^0.8.0;
interface IMagicNum {
    function setSolver(address _solver) external;
}
contract MagicNumAttacker {
    constructor(address target) {
        IMagicNum(target).setSolver(msg.sender);
    }
}