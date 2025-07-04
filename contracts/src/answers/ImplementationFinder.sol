// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract ImplementationFinder {
    function getImplementation() external view returns (address impl) {
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        assembly {
            impl := sload(slot)
        }
    }
}