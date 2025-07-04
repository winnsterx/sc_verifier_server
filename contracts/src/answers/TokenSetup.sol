// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/Dex.sol";

contract TokenSetup {
    function setupTokens(address dexAddress) external returns (address token1, address token2) {
        // Deploy two SwappableToken contracts
        SwappableToken t1 = new SwappableToken(dexAddress, "Token1", "TK1", 110);
        SwappableToken t2 = new SwappableToken(dexAddress, "Token2", "TK2", 110);
        
        token1 = address(t1);
        token2 = address(t2);
        
        // Transfer 100 of each to the DEX and keep 10
        t1.transfer(dexAddress, 100);
        t2.transfer(dexAddress, 100);
        
        return (token1, token2);
    }
}