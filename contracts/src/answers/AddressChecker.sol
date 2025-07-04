pragma solidity ^0.8.0;
abstract contract SimpleToken {
    function destroy(address payable _to) public virtual;
}

contract AddressChecker {
    function computeAddressForInstance(address instance, uint256 nonce) external view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes20(instance), nonce));
        return address(uint160(uint256(hash)));
    }

    function destroyToken(address token, address payable to) external {
        SimpleToken(token).destroy(to);
    }
}
