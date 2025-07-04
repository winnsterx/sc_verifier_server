pragma solidity ^0.8.0;

interface KingInterface {
    function prize() external view returns (uint256);
    function _king() external view returns (address);
}


contract AttackKing {
    KingInterface public king;

    constructor(address _kingAddress) {
        king = KingInterface(_kingAddress);
    }

    function attackWithZero() external {
        (bool success, ) = address(king).call{value: 0}({});
        require(success, "Initial zero value attack failed");
    }

    receive() external payable {
        // No reentrancy check; always accepts ETH
    }
}