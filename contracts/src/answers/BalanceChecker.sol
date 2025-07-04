// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function player() external view returns (address);
}

contract BalanceChecker {
    function getBalance(address token, address account) external view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }
    
    function getPlayer(address token) external view returns (address) {
        return IERC20(token).player();
    }
}