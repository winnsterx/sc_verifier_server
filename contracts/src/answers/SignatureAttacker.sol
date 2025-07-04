pragma solidity ^0.8.28;

contract SignatureAttacker {
    bytes32 private immutable prefix = 0x19457468657265756d205369676e6564204d6573736167653a0a3332;

    function calculateMsgHash(uint256 _id) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(prefix, _id));
    }
}
