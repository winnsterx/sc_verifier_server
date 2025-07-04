pragma solidity ^0.8.0;

contract DetectionBot {

    function handleTransaction(address user, bytes calldata msgData) external {
        // Intentionally does nothing to avoid triggering an alert
        // This means no alerts are raised during the transaction
        // So the fortaNotify modifier will not revert, allowing delegateTransfer to proceed
    }
}