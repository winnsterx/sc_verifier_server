// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract StorageHelper {
    function getSlotAsUint() external pure returns (uint256) {
        return uint256(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
    }
}