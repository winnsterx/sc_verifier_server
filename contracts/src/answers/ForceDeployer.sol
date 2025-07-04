// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceDeployer {
    function sendEth(address payable _target) public payable {
        selfdestruct(_target);
    }
}