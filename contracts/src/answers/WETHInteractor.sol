// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract WETHInteractor {
    IWETH public weth;
    address public stakeContract;
    
    constructor(address _weth, address _stake) {
        weth = IWETH(_weth);
        stakeContract = _stake;
    }
    
    function approveStake(uint256 amount) external {
        weth.approve(stakeContract, amount);
    }
    
    function checkAllowance() external view returns (uint256) {
        return weth.allowance(address(this), stakeContract);
    }
    
    function checkBalance() external view returns (uint256) {
        return weth.balanceOf(address(this));
    }
}