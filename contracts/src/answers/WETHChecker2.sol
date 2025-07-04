// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WETHChecker2 {
    event AllowanceResult(bool success, uint256 dataLength, bytes data);
    event TransferFromResult(bool success, uint256 dataLength, bytes data);
    
    function testAllowance(address weth, address owner, address spender) external {
        (bool success, bytes memory data) = weth.call(abi.encodeWithSelector(0xdd62ed3e, owner, spender));
        emit AllowanceResult(success, data.length, data);
    }
    
    function testTransferFrom(address weth, address from, address to, uint256 amount) external {
        (bool success, bytes memory data) = weth.call(abi.encodeWithSelector(0x23b872dd, from, to, amount));
        emit TransferFromResult(success, data.length, data);
    }
}