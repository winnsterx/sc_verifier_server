pragma solidity ^0.8.28;

contract SignatureGenerator {

    function generateSignature(uint256 lockId, address signer) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 messageHash = keccak256(abi.encodePacked(prefix, lockId));

        (v, r, s) = _sign(messageHash, signer);
        return (v, r, s);
    }

    function _sign(bytes32 digest, address signer) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        // In practice, signatures would be generated off-chain, but here we return a fake one.
        // For the sake of this example, let's assume we have a signature where v=27, r=0, s=0.
        // This is a common technique for exploiting signature handling by impersonating via correct structure.
        v = 27;
        r = 0;
        s = 0;
    }
}
