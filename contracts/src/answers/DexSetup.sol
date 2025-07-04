// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/Dex.sol";

contract DexSetup {
    Dex public dex;
    SwappableToken public token1;
    SwappableToken public token2;
    
    constructor(address _dex) {
        dex = Dex(_dex);
        
        // Deploy two tokens
        token1 = new SwappableToken(address(dex), "Token1", "TK1", 110);
        token2 = new SwappableToken(address(dex), "Token2", "TK2", 110);
        
        // Transfer some tokens to player for the attack
        token1.transfer(msg.sender, 10);
        token2.transfer(msg.sender, 10);
    }
    
    function setupDex() public {
        // Try to set tokens on dex if we're the owner
        try dex.setTokens(address(token1), address(token2)) {
            // Add liquidity
            token1.approve(address(dex), 100);
            token2.approve(address(dex), 100);
            dex.addLiquidity(address(token1), 100);
            dex.addLiquidity(address(token2), 100);
        } catch {
            revert("Failed to setup dex");
        }
    }
    
    function getTokenAddresses() public view returns (address, address) {
        return (address(token1), address(token2));
    }
}