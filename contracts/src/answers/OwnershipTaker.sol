// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IOwnable {
    function transferOwnership(address newOwner) external;
}

contract OwnershipTaker {
    function takeOwnership(address target) external {
        IOwnable(target).transferOwnership(msg.sender);
    }
}