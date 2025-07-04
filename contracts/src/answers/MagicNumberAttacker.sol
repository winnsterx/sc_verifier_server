pragma solidity ^0.8.0;

contract MagicNumberAttacker {
    address public targetInstance;

    constructor(address _targetInstance) {
        targetInstance = _targetInstance;
    }

    function setSolver() public {
        // Assuming the MagicNum instance has logic to call this from fallback
        (bool success, ) = targetInstance.call("");
        require(success, "Call failed");
    }

    // Fallback function to match required logic
    fallback() external {
        (bool success, ) = targetInstance.call(abi.encodeWithSignature("setSolver(address)"));
        require(success, "Fallback call failed");
    }
}
