// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasConsumer {
    fallback() external payable {
        uint256 i = 0;
        while (i < 10000000000000000) i++;
    }
}