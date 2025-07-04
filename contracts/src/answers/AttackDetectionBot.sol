pragma solidity ^0.8.0;

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
    function raiseAlert(address user) external;
    function botRaisedAlerts(address detectionBot) public view returns (uint256);
}

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}


contract AttackDetectionBot is IDetectionBot {
    address public player = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public forta = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

    constructor() {
        // Initialize with no-op values
    }

    function handleTransaction(address user, bytes calldata _msgData) external override {
        // Do nothing to prevent alert triggering
    }

    function setAsPlayerBot() public {
        IForta(forta).setDetectionBot(player, address(this));
    }
} 