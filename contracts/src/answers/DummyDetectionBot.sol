pragma solidity ^0.8.0;

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}



contract DummyDetectionBot is IDetectionBot {
    function handleTransaction(address, bytes calldata) external override {
        // Do nothing to allow delegateTransfer without alerts
    }
}