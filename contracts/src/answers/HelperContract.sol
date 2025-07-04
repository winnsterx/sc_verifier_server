// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelperContract {
    function toHex(uint256 value) external pure returns (bytes32) {
        return bytes32(value);
    }
    
    function getEncodedApprove(address spender, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("approve(address,uint256)", spender, amount);
    }
}