pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
}


contract CorrectAttacker {
    uint256 public attackPrice = 100;

    function setPriceTo100() public {
        attackPrice = 100;
    }
    function buyShop(address shopAddress) external {
        Shop shop = Shop(shopAddress);
        shop.buy();
    }
    function price() external view returns (uint256) {
        return attackPrice;
    }
}