pragma solidity ^0.8.0;

contract MagicNumberAttackerFixed {
    address public targetInstance;
    address public solverAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    constructor(address _targetInstance) {
        targetInstance = _targetInstance;
    }

    function setSolver() public {
        (bool success, ) = targetInstance.call(abi.encodeWithSignature("setSolver(address)", solverAddress));
        require(success, "Call failed");
    }

    fallback() external {
        (bool success, ) = targetInstance.call(abi.encodeWithSignature("setSolver(address)", solverAddress));
        require(success, "Fallback call failed");
    }
}
