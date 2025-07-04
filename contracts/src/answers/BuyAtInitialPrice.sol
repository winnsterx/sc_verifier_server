pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
}


contract BuyAtInitialPrice {
    function purchase() external {
        Shop(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be).buy();
    }

    function price() external view returns (uint256) {
        return 100; // Match the initial price
    }
}