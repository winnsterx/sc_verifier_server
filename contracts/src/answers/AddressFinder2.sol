pragma solidity ^0.8.0;abstract contract SimpleToken {
    function destroy(address payable _to) public virtual;
}
contract AddressFinder2 {
    function findTokenAddress(address instance) external view returns (address) {
        address tokenAddress;
        for (uint8 i=1; i<=20; i++) {
            bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), instance, abi.encodePacked(i)));
            address token = address(uint160(uint256(hash)));
            if (token != address(0)) {
                tokenAddress = token;
                break;
            }
        }     
        return tokenAddress;
    }

    function destroySimpleToken(address token, address payable to) external {
        SimpleToken(token).destroy(to);
    }
} 