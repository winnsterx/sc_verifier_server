pragma solidity ^0.8.0;

address public constant ETC_ADDRESS = 0x1688bce0D4733975Ffcf1Fcd2E75502f6866d1d3;

contract CorrectAddressFinder {
    address public computedTokenAddress;

    function computeAddress(address creator, uint256 nonce) public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(creator, nonce)))));
    }

    function destroyToken(address tokenAddress, address payable to) public {
        (bool success,) = tokenAddress.call(abi.encodeWithSignature("destroy(address payable)\