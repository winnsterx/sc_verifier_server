// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WETHChecker {
    function checkWETH(address weth) external view returns (uint256 codeSize, bool isContract) {
        assembly {
            codeSize := extcodesize(weth)
        }
        isContract = codeSize > 0;
    }
    
    function callAllowance(address weth, address owner, address spender) external returns (bool success, bytes memory data) {
        (success, data) = weth.call(abi.encodeWithSelector(0xdd62ed3e, owner, spender));
    }
}