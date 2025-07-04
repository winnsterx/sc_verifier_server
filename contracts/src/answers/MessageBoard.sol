// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MessageBoard {
    string public message;
    address public lastSender;

    // Set a new message
    function postMessage(string calldata _message) public {
        message = _message;
        lastSender = msg.sender;
    }

    // Get the current message
    function readMessage() public view returns (string memory, address) {
        return (message, lastSender);
    }
}