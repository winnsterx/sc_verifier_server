pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
}

contract CorrectBuyer {
    function buyerPrice() public view returns (uint256) {
        return 100;
    }

    function attackShop(address shopAddress) external {
        Shop(shopAddress).buy();
    }

    function price() external view returns (uint256) {
        return buyerPrice();
    }
}