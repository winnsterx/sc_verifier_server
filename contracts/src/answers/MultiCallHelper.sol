// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiCallHelper {
    function getEncodedData() external pure returns (bytes[] memory) {
        // Create deposit selector
        bytes memory depositData = abi.encodeWithSignature("deposit()");
        
        // Create nested multicall with deposit
        bytes[] memory nestedCalls = new bytes[](1);
        nestedCalls[0] = depositData;
        bytes memory nestedMulticall = abi.encodeWithSignature("multicall(bytes[])", nestedCalls);
        
        // Create main call array
        bytes[] memory calls = new bytes[](2);
        calls[0] = depositData;
        calls[1] = nestedMulticall;
        
        return calls;
    }
}