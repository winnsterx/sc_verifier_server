pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}



contract AddressFinder {
    address public constant RECOVERY = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;

    function getSimpleTokenAddress() public pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(RECOVERY, uint256(1)));
        return address(uint160(uint256(hash) >> 96));
    }

    function triggerSelfDestruct() public {
        address token = getSimpleTokenAddress();
        ISimpleToken(token).destroy(payable(msg.sender));
    }
}