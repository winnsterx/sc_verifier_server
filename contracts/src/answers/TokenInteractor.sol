// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenInteractor {
    function getApproveData(address spender, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("approve(address,uint256)", spender, amount);
    }
    
    function getTransferFromData(address from, address to, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount);
    }
}