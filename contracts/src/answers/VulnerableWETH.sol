pragma solidity ^0.8.0;

interface IERC20 {
    function allowance(address, address) external view returns (uint256);
    function transferFrom(address, address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function decimals() external pure returns (uint8);
}

contract VulnerableWETH is IERC20 {
    address public immutable stakeInstance;

    constructor(address _stakeInstance) {
        stakeInstance = _stakeInstance;
    }

    function allowance(address, address) external view returns (uint256) {
        return 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        return true;
    }

    function approve(address, uint256) external returns (bool) {
        return true;
    }

    function balanceOf(address) external view returns (uint256) {
        return 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }
}
contract Attacker {

}