pragma solidity ^0.8.0;

contract MagicNumberAttack {
    function exploit() public returns (bytes4) {
        return bytes4(keccak256("call"));
    }

    fallback() external payable {
        assembly {
            mstore(0, 0x63616c6c)
            return(0, 4)
        }
    }
}
