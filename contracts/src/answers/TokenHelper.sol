// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract TokenHelper {
    // This contract will help us properly interact with the ERC20 token
    
    function approveToken(address token, address spender, uint256 amount) external {
        IERC20(token).approve(spender, amount);
    }
    
    function transferFromToken(address token, address from, address to, uint256 amount) external {
        IERC20(token).transferFrom(from, to, amount);
    }
    
    function checkAllowance(address token, address owner, address spender) external view returns (uint256) {
        return IERC20(token).allowance(owner, spender);
    }
    
    function checkBalance(address token, address account) external view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }
}