pragma solidity ^0.8.0;

contract Answer {
    constructor() {}

    fallback() external payable {
        assembly {
            mstore(0x00, 0x213a31)
            return(0, 32)
        }
    }
}