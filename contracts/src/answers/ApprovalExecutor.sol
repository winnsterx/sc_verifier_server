// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ApprovalExecutor {
    // This will help us execute the approval
    function executeApprove(address token, address spender) external returns (bool) {
        // Encode the approve function call
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", spender, uint256(1000000000000000000000000));
        
        // Make the call
        (bool success, bytes memory result) = token.call(data);
        require(success, "Approve failed");
        
        return abi.decode(result, (bool));
    }
    
    function executeTransferFrom(address token, address from, address to) external returns (bool) {
        uint256 amount = 1000000000000000000000000;
        bytes memory data = abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount);
        
        (bool success, bytes memory result) = token.call(data);
        require(success, "TransferFrom failed");
        
        return abi.decode(result, (bool));
    }
}