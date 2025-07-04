pragma solidity ^0.8.0;

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

contract DoubleEntryPointAttack {
    IDetectionBot private detectionBot;

    constructor(address _detectionBotAddress) {
        detectionBot = IDetectionBot(_detectionBotAddress);
    }

    function exploit() external {
        detectionBot.handleTransaction(address(0), new bytes(0));
    }
}
