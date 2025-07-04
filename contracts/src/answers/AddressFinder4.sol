pragma solidity ^0.8.0;abstract contract SimpleToken {
    function destroy(address payable _to) public virtual;
}
contract AddressFinder4 {
    function findTokenAddress(address instance) external view returns (address) {
        address tokenAddress;
        for (uint8 i=0; i<=200; i++) {
            address token = computeAddress(instance, i);
            if (token != address(0)) {
                tokenAddress = token;
                break;
            }
        }
        return tokenAddress;
    }

    function computeAddress(address sender, uint8 nonce) internal pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes20(sender), nonce));
        return address(uint160(uint256(hash)));
    }

    function destroySimpleToken(address token, address payable to) external {
        SimpleToken(token).destroy(to);
    }
}
