// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DirectCaller {
    function callApprove(address token, address spender) external returns (bool success) {
        uint256 amount = 1000000 * 10**18; // 1 million tokens with 18 decimals
        
        // Manually encode the approve function call
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", spender, amount);
        
        // Make the call
        (success,) = token.call(data);
        require(success, "Approve call failed");
    }
    
    function callTransferFrom(address token, address from, address to) external returns (bool success) {
        uint256 amount = 1000000 * 10**18; // 1 million tokens with 18 decimals
        
        // Manually encode the transferFrom function call
        bytes memory data = abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount);
        
        // Make the call
        (success,) = token.call(data);
        require(success, "TransferFrom call failed");
    }
}