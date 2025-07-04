pragma solidity ^0.8.0;
contract FakeWETH {
    function allowance(address, address) external view returns (uint256) {
        return 1000000000000000000000;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        return true;
    }
} 