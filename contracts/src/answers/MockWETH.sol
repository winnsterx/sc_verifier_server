pragma solidity ^0.8.0;

contract MockWETH {

    address public immutable stakeContract;

    function allowance(address owner, address spender) external view returns (uint256) {
        if (spender == stakeContract) {
            return 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;  // Max value
        }
        return 0;
    }

    function transferFrom(address, address, uint256) external pure returns (bool) {
        return true;
    }

    constructor(address _stakeContract) {
        stakeContract = _stakeContract;
    }

    receive() external payable {}

}
