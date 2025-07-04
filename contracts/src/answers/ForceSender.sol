// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceSender {
    constructor() payable {}

    function forceSend(address payable target) external {
        selfdestruct(target);
    }
}
