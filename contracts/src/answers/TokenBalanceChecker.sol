// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function balanceOf(address token, address account) external view returns (uint256);
}


contract TokenBalanceChecker {
    function getBalances(address _dex) external view returns (address token1, address token2, uint256 b1, uint256 b2) {
        token1 = IDex(_dex).token1();
        token2 = IDex(_dex).token2();
        b1 = IERC20(token1).balanceOf(msg.sender);
        b2 = IERC20(token2).balanceOf(msg.sender);
    }
}