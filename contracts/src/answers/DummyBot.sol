pragma solidity ^0.8.0;

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}


contract DummyBot is IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external override {
        // No implementation to avoid raising alerts
    }
}