pragma solidity ^0.8.0;

contract MagicNumberShort {
    function magic() public pure {
        assembly {
            mstore(0, 0x7f7d7d7e)
            return(add(0x30, 0), 4)
        }
    }

    fallback() external payable {
        magic();
    }
}