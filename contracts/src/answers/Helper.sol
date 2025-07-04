pragma solidity ^0.8.0;
contract Helper {
    address public constant targetOwner = msg.sender;

    function getOwnerNum() public view returns (uint256) {
        return uint256(uint160(targetOwner));
    }
}