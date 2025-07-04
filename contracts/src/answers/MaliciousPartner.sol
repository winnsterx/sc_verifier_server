// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MaliciousPartner {
    // Fallback function that reverts
    fallback() external payable {
        // Consume all gas
        while (true) {}
    }
}