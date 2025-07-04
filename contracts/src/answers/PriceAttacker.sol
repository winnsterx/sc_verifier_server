pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
    function price() external view returns (uint256);
}

contract PriceAttacker {
    function buyShop() external {
        Shop shop = Shop(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be);
        shop.buy(); // Buyer price is 100, matches initial Shop price
    }

    function price() external view returns (uint256) {
        return 100; // Exact initial price of the Shop
    }
}