pragma solidity ^0.8.0;

interface BuyerI {
    function price() external view returns (uint256);
}

contract Buyer is BuyerI {
    function price() external view override returns (uint256) {
        return 100;
    }

    function callBuy() public {
        // No action needed here since the Shop's buy() will be called externally
    }
}
