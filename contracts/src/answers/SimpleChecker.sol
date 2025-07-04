// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/Dex.sol";

contract SimpleChecker {
    function checkDexState(address dexAddr) public view returns (
        address owner,
        address token1, 
        address token2,
        bool hasTokens
    ) {
        Dex dex = Dex(dexAddr);
        
        // Try to get owner
        try dex.owner() returns (address _owner) {
            owner = _owner;
        } catch {
            owner = address(0);
        }
        
        // Try to get tokens
        try dex.token1() returns (address _token1) {
            token1 = _token1;
        } catch {
            token1 = address(0);
        }
        
        try dex.token2() returns (address _token2) {
            token2 = _token2;
        } catch {
            token2 = address(0);
        }
        
        hasTokens = (token1 != address(0)) && (token2 != address(0));
    }
}