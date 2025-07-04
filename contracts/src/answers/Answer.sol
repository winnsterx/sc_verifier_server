pragma solidity ^0.8.6;

interface IMagicNum {
    function setSolver(address) external;
}


contract Answer {
    fallback() external {
        assembly {
            mstore(0x00, 0x213a31)
            return(0x00, 28) // Return 4 magic bytes and 28 zeros as per 
        }
    }
}