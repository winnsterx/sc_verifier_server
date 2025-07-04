pragma solidity ^0.8.0;

contract MagicNumberAnswer {
    function magicNumber() public pure returns (bytes1) {
        assembly {
            mstore(0x00, 0x2a)
            return(0x00, 0x20)
        }
    }
}
