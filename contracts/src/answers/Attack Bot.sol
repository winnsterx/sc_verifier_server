pragma solidity ^0.8.0;

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

contract AttackBot is IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) public override {
        // Intentionally empty - will not trigger forta alerts
    }
}