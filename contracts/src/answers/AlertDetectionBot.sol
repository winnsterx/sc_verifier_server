pragma solidity ^0.8.0;

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
};

address constant FOREALERT = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

contract AlertDetectionBot is IDetectionBot {

    function handleTransaction(address user, bytes calldata msgData) external override {
        if (user == 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) {
            IForta(FOREALERT).raiseAlert(user);
        }
    }
}

interface IForta {
    function raiseAlert(address user) external;
};