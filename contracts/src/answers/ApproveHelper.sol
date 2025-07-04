// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ApproveHelper {
    function approveMax(address token, address spender) external {
        IERC20 erc20 = IERC20(token);
        uint256 balance = erc20.balanceOf(msg.sender);
        erc20.approve(spender, balance);
    }
}