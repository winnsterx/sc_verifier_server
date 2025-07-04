// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestContract {
    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}