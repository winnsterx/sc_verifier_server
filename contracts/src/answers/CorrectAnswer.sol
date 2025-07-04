pragma solidity ^0.8.0;

interface IMagicNum {
    function setSolver(address) external;
}


contract CorrectAnswer {
    fallback() external payable {
        assembly {
            mstore(0x00, 0xdeadbeef)
            return(0x00, 0x20)
        }
    }

    // Constructor may not be needed
}
